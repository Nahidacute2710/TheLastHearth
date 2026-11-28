extends "res://tests/test_case.gd"
## VSA4: audio buses, the sound library and which gameplay events play which sound.

const LIBRARY_PATH: String = "res://data/audio/sfx_library.tres"
const MINER_SCENE: String = "res://scenes/enemies/hollow_miner.tscn"
const SfxLibraryScript: GDScript = preload("res://scripts/audio/sfx_library.gd")


func _audio() -> Node:
	return main.find_child("Audio", true, false)


func _played() -> Array[StringName]:
	return _audio().get("played")


func _library() -> Resource:
	return load(LIBRARY_PATH)


func test_buses_master_music_sfx() -> void:
	for bus: StringName in [&"Master", &"Music", &"SFX"]:
		check(AudioServer.get_bus_index(bus) >= 0, "bus %s exists" % bus)
	check_eq(AudioServer.get_bus_send(AudioServer.get_bus_index(&"Music")), &"Master", "Music goes to Master")
	check_eq(AudioServer.get_bus_send(AudioServer.get_bus_index(&"SFX")), &"Master", "SFX goes to Master")


func test_every_sound_id_has_a_stream() -> void:
	var library: Resource = _library()
	for id: StringName in SfxLibraryScript.IDS:
		var stream: AudioStream = library.call("get_stream", id)
		check(stream != null, "%s has a stream" % id)
		if stream != null:
			check(stream.get_length() > 0.0, "%s is not empty" % id)


func test_enemy_windup_stands_out() -> void:
	var library: Resource = _library()
	var windup: float = (library.call("get_stream", &"enemy_windup") as AudioStream).get_length()
	check(windup >= 0.4, "wind-up sound lasts most of the wind-up (%.2f s)" % windup)
	for id: StringName in [&"swing", &"hit", &"dodge", &"pickup", &"coin", &"ui_click"]:
		var length: float = (library.call("get_stream", id) as AudioStream).get_length()
		check(windup > length * 2.0, "wind-up is much longer than %s" % id)


func test_sounds_play_on_the_sfx_bus_by_id() -> void:
	await boot_to_menu()
	tree.root.get_node("EventBus").emit_signal("sfx_requested", &"coin")
	check_eq(_played().back(), &"coin", "coin played")
	check_eq(_audio().call("get_player_bus"), &"SFX", "players use the SFX bus")


func test_unknown_id_is_ignored_with_a_warning() -> void:
	await boot_to_menu()
	var before: int = _played().size()
	tree.root.get_node("EventBus").emit_signal("sfx_requested", &"no_such_sound")
	check_eq(_played().size(), before, "nothing played")


func test_buttons_click() -> void:
	await boot_to_menu()
	main.find_child("SettingsButton", true, false).emit_signal("pressed")
	check(_played().has(&"ui_click"), "menu button clicks")
	var settings: Node = main.find_child("SettingsMenu", true, false)
	_played().clear()
	settings.call("start_rebind", &"dodge")
	check(_played().has(&"ui_click"), "buttons built in code click too")


func test_player_actions_play_sounds() -> void:
	await start_main()
	var state: Node = tree.root.get_node("GameState")
	state.call("equip_weapon", load("res://data/items/rusty_pickaxe.tres"))
	check(player().call("attack_towards", Vector2.RIGHT), "swing started")
	check(_played().has(&"swing"), "swing sound")
	await wait(0.6)
	check(player().call("dodge", Vector2.LEFT), "dodge started")
	check(_played().has(&"dodge"), "dodge sound")


func test_world_events_play_sounds() -> void:
	await start_main()
	var state: Node = tree.root.get_node("GameState")
	var mushroom: Resource = load("res://data/items/cave_mushroom.tres")
	var stew: Resource = load("res://data/items/mushroom_stew.tres")
	state.get("stash").call("add", mushroom, 2)
	player().global_position = Vector2(520, 110)
	await wait_physics(5)
	await tap(&"interact")
	await wait(2.2)
	check(_played().has(&"cook_done"), "cooking done sound")
	state.get("stash").call("add", stew, 1)
	player().global_position = Vector2(430, 340)
	await wait_physics(5)
	await tap(&"interact")
	check(_played().has(&"coin"), "coin sound when the customer pays")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	level().call("spawn_pickup", mushroom, 1, Vector2(64, 120))
	await wait_physics(2)
	player().global_position = Vector2(64, 120)
	await wait_physics(5)
	check(_played().has(&"pickup"), "pickup sound")


func test_enemy_windup_and_hit_sounds() -> void:
	await start_main()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	tree.root.get_node("GameState").call("equip_weapon", load("res://data/items/rusty_pickaxe.tres"))
	var miner: CharacterBody2D = (load(MINER_SCENE) as PackedScene).instantiate() as CharacterBody2D
	level().call("add_enemy", miner, player().global_position + Vector2(14, 0))
	miner.call("set_target", player())
	await wait(0.3)
	check(_played().has(&"enemy_windup"), "wind-up sound when the miner starts its attack")
	await wait(0.7)
	check(_played().has(&"hit"), "hit sound when the player is struck")


func test_leaving_mid_cook_is_silent() -> void:
	await start_main()
	var state: Node = tree.root.get_node("GameState")
	state.get("stash").call("add", load("res://data/items/cave_mushroom.tres"), 2)
	player().global_position = Vector2(520, 110)
	await wait_physics(5)
	await tap(&"interact")
	_played().clear()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	check(not _played().has(&"cook_done"), "no cooking sound while the tavern unloads")
	check_eq(state.get("stash").call("count_of", load("res://data/items/mushroom_stew.tres")), 1, "dish still stored")
