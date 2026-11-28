extends "res://tests/test_case.gd"
## VS-E1: Ember Coal and coal veins in the mine.

const COAL_PATH: String = "res://data/items/ember_coal.tres"
const MINE_SCENE: String = "res://scenes/dungeon/abandoned_mine.tscn"
const MINER_SCENE: String = "res://scenes/enemies/hollow_miner.tscn"
const PICKAXE_PATH: String = "res://data/items/rusty_pickaxe.tres"


func _state() -> Node:
	return tree.root.get_node("GameState")


func _coal() -> Resource:
	return load(COAL_PATH)


func _veins(in_level: Node) -> Array[Node]:
	var found: Array[Node] = []
	for child: Node in in_level.get_node("Entities").get_children():
		if child is OreVein and not child.is_queued_for_deletion():
			found.append(child)
	return found


func _go_to_mine_without_miners() -> void:
	await start_main()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	for child: Node in level().get_node("Entities").get_children():
		if child.name.begins_with("Miner"):
			child.queue_free()
	player().call("set_god_mode", true)
	_state().call("equip_weapon", load(PICKAXE_PATH))
	await wait_physics(2)


## Swings at the vein from its left until it breaks or `max_swings` runs out. Returns the swings used.
func _mine(vein: Node2D, max_swings: int) -> int:
	player().global_position = vein.global_position + Vector2(-18, 0)
	player().reset_physics_interpolation()
	await wait_physics(2)
	var swings: int = 0
	while is_instance_valid(vein) and not vein.is_queued_for_deletion() and swings < max_swings:
		player().call("attack_towards", Vector2.RIGHT)
		swings += 1
		await wait(0.45)
	return swings


func test_ember_coal_item() -> void:
	var coal: Resource = _coal()
	check_eq(coal.get("id"), &"ember_coal", "id ember_coal")
	check_eq(ItemDB.get_item(&"ember_coal"), coal, "listed in ItemDB")
	check(not bool(coal.get("is_quest_item")), "not a quest item (lost on death like mushrooms)")
	check_eq(tr(coal.get("name_key")), "Ember Coal", "translated name")


func test_every_vein_spot_is_reachable_and_in_its_own_room() -> void:
	var mine: Node2D = (load(MINE_SCENE) as PackedScene).instantiate() as Node2D
	mine.set("min_veins", 4)
	mine.set("max_veins", 4)
	tree.root.add_child(mine)
	await tree.process_frame
	var walls: TileMapLayer = mine.get_node("Walls") as TileMapLayer
	var rooms: Array[StringName] = []
	for vein: Node in _veins(mine):
		var at: Vector2 = (vein as Node2D).global_position
		for offset: Vector2 in [Vector2.ZERO, Vector2(-12, 0), Vector2(12, 0), Vector2(0, -16), Vector2(-24, 0)]:
			var cell: Vector2i = walls.local_to_map(walls.to_local(at + offset))
			check_eq(walls.get_cell_source_id(cell), -1, "%s (and the spot to mine it from) is not in a wall" % vein.name)
		rooms.append(vein.get("room"))
	check_eq(rooms.size(), 4, "one vein spot per room")
	for room: StringName in rooms:
		check_eq(rooms.count(room), 1, "room %s has one spot" % room)
	mine.queue_free()
	await tree.process_frame


func test_each_visit_has_two_or_three_veins_in_different_rooms() -> void:
	await start_main()
	var counts: Array[int] = []
	for visit: int in 4:
		router().call("go_to", &"dungeon", &"entrance")
		await wait(0.8)
		var veins: Array[Node] = _veins(level())
		counts.append(veins.size())
		check(veins.size() >= 2 and veins.size() <= 3, "2–3 veins (got %d)" % veins.size())
		var rooms: Array = veins.map(func(v: Node) -> StringName: return v.get("room"))
		for room: Variant in rooms:
			check_eq(rooms.count(room), 1, "veins are in different rooms")
		router().call("go_to", &"tavern", &"cellar_door")
		await wait(0.8)


func test_three_swings_break_the_vein_and_drop_two_or_three_coal() -> void:
	await _go_to_mine_without_miners()
	var vein: Node2D = _veins(level())[0] as Node2D
	var vein_at: Vector2 = vein.global_position
	var played: Array[StringName] = main.find_child("Audio", true, false).get("played")
	played.clear()
	player().global_position = vein_at + Vector2(-18, 0)
	await wait_physics(2)
	player().call("attack_towards", Vector2.RIGHT)
	await wait(0.45)
	check_eq(vein.call("get_hits_left"), 2, "one swing takes one hit")
	check(played.has(&"ore_hit"), "ore_hit sound on a hit")
	check(not played.has(&"hit"), "no flesh hit sound on the vein")
	var swings: int = 1 + await _mine(vein, 5)
	check_eq(swings, 3, "the vein breaks on the third swing")
	check(played.has(&"ore_break"), "ore_break sound")
	await wait_physics(3)
	var coal_on_floor: int = 0
	for child: Node in level().get_node("Entities").get_children():
		if child is Pickup and child.get("item") == _coal():
			coal_on_floor += int(child.get("count"))
	# A drop can land under the player and be picked up at once: count the bag too.
	var dropped: int = coal_on_floor + int(_state().get("bag").call("count_of", _coal()))
	check(dropped >= 2 and dropped <= 3, "2–3 Ember Coal dropped (got %d)" % dropped)
	# Walk over the drops: they go to the bag and the HUD counts them.
	for child: Node in level().get_node("Entities").get_children():
		if is_instance_valid(child) and child is Pickup and child.get("item") == _coal():
			player().global_position = (child as Node2D).global_position
			await wait_physics(4)
	check_eq(_state().get("bag").call("count_of", _coal()), dropped, "all the coal is in the bag")
	var hud: Node = main.find_child("HUD", true, false)
	check_eq(hud.call("get_coal_count_text"), "×%d" % dropped, "HUD counts the coal")


func test_mining_never_hurts_or_triggers_enemies() -> void:
	await _go_to_mine_without_miners()
	var vein: Node2D = _veins(level())[0] as Node2D
	var deaths: Array[int] = [0]
	var on_death: Callable = func(_data: Resource, _at: Vector2) -> void: deaths[0] += 1
	EventBus.enemy_died.connect(on_death)
	# A miner right behind the player (outside the swing) while the player mines.
	var miner: CharacterBody2D = (load(MINER_SCENE) as PackedScene).instantiate() as CharacterBody2D
	level().call("add_enemy", miner, vein.global_position + Vector2(-40, 0))
	var miner_health: HealthComponent = miner.get_node("Health") as HealthComponent
	await _mine(vein, 5)
	check_eq(miner_health.current_health, miner_health.max_health, "the miner took no damage")
	check_eq(deaths[0], 0, "breaking a vein is not an enemy death (no enemy loot)")
	EventBus.enemy_died.disconnect(on_death)
	# Enemy attacks only look at the player hurtbox layer, never at a vein.
	var hitbox_mask: int = (miner.get_node("AttackPivot/AttackHitbox") as Area2D).collision_mask
	var vein_scene: Node = (load("res://scenes/dungeon/ore_vein.tscn") as PackedScene).instantiate()
	var vein_layer: int = (vein_scene.get_node("Hurtbox") as Area2D).collision_layer
	check_eq(hitbox_mask & vein_layer, 0, "enemy hitbox cannot hit a vein")
	vein_scene.free()


func test_coal_follows_bag_rules() -> void:
	await start_main()
	var coal: Resource = _coal()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	_state().get("bag").call("add", coal, 3)
	router().call("go_to", &"tavern", &"cellar_door")
	await wait(0.8)
	check_eq(_state().get("stash").call("count_of", coal), 3, "safe return stores the coal")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	_state().get("bag").call("add", coal, 2)
	player().get("_health").call("take_damage", 999)
	await wait(1.6)
	check_eq(_state().get("bag").call("count_of", coal), 0, "death loses the coal in the bag")
	check_eq(_state().get("stash").call("count_of", coal), 3, "the stash keeps its coal")
