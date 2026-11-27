extends "res://tests/test_case.gd"

const MUSHROOM_PATH: String = "res://data/items/cave_mushroom.tres"


func _bag() -> RefCounted:
	return tree.root.get_node("GameState").get("bag")


func _mushrooms_near(at: Vector2, radius: float) -> int:
	var found: int = 0
	for child: Node in level().get_node("Entities").get_children():
		if child is Area2D and child.get("item") == load(MUSHROOM_PATH) and (child as Node2D).position.distance_to(at) < radius:
			found += 1
	return found


func test_miner_has_mushroom_loot() -> void:
	var data: Resource = load("res://data/enemies/hollow_miner.tres")
	var loot: Array = data.get("loot")
	check_eq(loot.size(), 1, "miner has one loot entry")
	check_eq(loot[0].get("item"), load(MUSHROOM_PATH), "the entry drops Cave Mushroom")


func test_mine_has_preplaced_mushrooms_outside_walls() -> void:
	await start_main()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	var walls: TileMapLayer = level().get_node("Walls") as TileMapLayer
	var count: int = 0
	for child: Node in level().get_node("Entities").get_children():
		if child is Area2D and child.get("item") == load(MUSHROOM_PATH):
			count += 1
			var cell: Vector2i = walls.local_to_map(walls.to_local((child as Node2D).global_position))
			check_eq(walls.get_cell_source_id(cell), -1, "%s is not inside a wall" % child.name)
	check_eq(count, 4, "four mushrooms grow in the mine")


func test_walking_over_pickup_adds_to_bag_and_hud() -> void:
	await start_main()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	var mushroom: Resource = load(MUSHROOM_PATH)
	var pickup: Node = level().call("spawn_pickup", mushroom, 2, Vector2(64, 120))
	await wait_physics(2)
	player().global_position = Vector2(64, 120)
	await wait_physics(5)
	check_eq(_bag().call("count_of", mushroom), 2, "2 mushrooms in the bag")
	check(not is_instance_valid(pickup) or pickup.is_queued_for_deletion(), "pickup is removed")
	var hud: Node = main.find_child("HUD", true, false)
	check_eq(hud.call("get_item_count_text"), "×2", "HUD counts the mushrooms")


func test_full_bag_leaves_remainder_on_the_ground() -> void:
	await start_main()
	var mushroom: Resource = load(MUSHROOM_PATH)
	var filler: Resource = load("res://data/items/rusty_pickaxe.tres")
	for i: int in 11:
		_bag().call("add", filler, 1)
	_bag().call("add", mushroom, 19)
	var pickup: Node = level().call("spawn_pickup", mushroom, 3, Vector2(300, 240))
	await wait_physics(2)
	player().global_position = Vector2(300, 240)
	await wait_physics(5)
	check_eq(_bag().call("count_of", mushroom), 20, "only 1 more fits in the full bag")
	check(is_instance_valid(pickup) and not pickup.is_queued_for_deletion(), "pickup stays")
	check_eq(pickup.get("count"), 2, "the rest stays on the ground")


func test_killed_miner_drops_loot() -> void:
	await start_main()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	var miner: Node2D = (load("res://scenes/enemies/hollow_miner.tscn") as PackedScene).instantiate() as Node2D
	var data: Resource = (load("res://data/enemies/hollow_miner.tres") as Resource).duplicate(true)
	(data.get("loot") as Array)[0].set("chance", 1.0)
	miner.set("data", data)
	level().call("add_enemy", miner, Vector2(200, 300))
	await wait_physics(2)
	var before: int = _mushrooms_near(Vector2(200, 300), 12.0)
	miner.get_node("Health").call("take_damage", 99)
	await wait(0.1)
	check_eq(_mushrooms_near(Vector2(200, 300), 12.0) - before, 1, "a mushroom drops where the miner died")
