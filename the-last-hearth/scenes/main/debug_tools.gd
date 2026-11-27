extends Node
## Debug-only hotkeys for quick playtesting. Freed immediately in release builds.
## F1: toggle EN/VI · F2: go to the mine · F3: go to the tavern
## F4: heal to full · F9: kill the player · F10: spawn a Hollow Miner next to the player · F11: toggle god mode
## Shift+F1: +5 Cave Mushroom in the bag · Shift+F2: +5 in the stash · Shift+F3: next day · Shift+F4: +50 gold

const MINER_SCENE: PackedScene = preload("res://scenes/enemies/hollow_miner.tscn")
const SPAWN_OFFSET: Vector2 = Vector2(40.0, 0.0)
const MUSHROOM: ItemData = preload("res://data/items/cave_mushroom.tres")
const DEBUG_ITEM_AMOUNT: int = 5
const DEBUG_GOLD_AMOUNT: int = 50


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.shift_pressed:
		_handle_shift_key(key.physical_keycode)
		return
	match key.physical_keycode:
		KEY_F1:
			var next_locale: String = "en" if TranslationServer.get_locale().begins_with("vi") else "vi"
			TranslationServer.set_locale(next_locale)
			print("Debug: locale = %s" % next_locale)
		KEY_F2:
			SceneRouter.go_to(SceneRouter.DUNGEON, &"entrance")
		KEY_F3:
			SceneRouter.go_to(SceneRouter.TAVERN, &"cellar_door")
		KEY_F4:
			var player: Player = _get_player()
			if player != null:
				player.heal_full()
		KEY_F9:
			var player: Player = _get_player()
			if player != null:
				player.get_health().take_damage(9999)
		KEY_F10:
			var level: Level = SceneRouter.get_current_level()
			var player: Player = _get_player()
			if level != null and player != null:
				level.add_enemy(MINER_SCENE.instantiate() as Node2D, player.global_position + SPAWN_OFFSET)
		KEY_F11:
			var player: Player = _get_player()
			if player != null:
				player.set_god_mode(not player.is_god_mode())
				print("Debug: god mode = %s" % player.is_god_mode())


func _handle_shift_key(keycode: Key) -> void:
	match keycode:
		KEY_F1:
			GameState.bag.add(MUSHROOM, DEBUG_ITEM_AMOUNT)
		KEY_F2:
			GameState.stash.add(MUSHROOM, DEBUG_ITEM_AMOUNT)
		KEY_F3:
			GameState.advance_day()
		KEY_F4:
			GameState.add_gold(DEBUG_GOLD_AMOUNT)


func _get_player() -> Player:
	var level: Level = SceneRouter.get_current_level()
	return level.get_player() if level != null else null
