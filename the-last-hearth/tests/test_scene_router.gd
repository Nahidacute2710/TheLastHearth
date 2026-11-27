extends "res://tests/test_case.gd"

const HATCH_POS: Vector2 = Vector2(688, 418)
const LADDER_POS: Vector2 = Vector2(64, 44)


func test_hatch_and_ladder_switch_levels() -> void:
	await start_main()
	check_eq(level().name, &"TavernMainHall", "starts in tavern")
	player().global_position = HATCH_POS
	await wait(0.2)
	await tap(&"interact")
	await wait(0.8)
	check_eq(level().name, &"AbandonedMine", "hatch leads to mine")
	check_eq(player().global_position, Vector2(64, 72), "spawn at mine entrance")
	check_eq(main.get_node("LevelRoot").get_child_count(), 1, "only one level loaded")
	player().global_position = LADDER_POS
	await wait(0.2)
	await tap(&"interact")
	await wait(0.8)
	check_eq(level().name, &"TavernMainHall", "ladder leads back to tavern")
	check_eq(player().global_position, Vector2(688, 380), "spawn next to hatch")


func test_round_trips_do_not_leak_nodes() -> void:
	await start_main()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	router().call("go_to", &"tavern", &"cellar_door")
	await wait(0.8)
	var baseline: int = node_count()
	for i: int in 3:
		router().call("go_to", &"dungeon", &"entrance")
		await wait(0.8)
		router().call("go_to", &"tavern", &"cellar_door")
		await wait(0.8)
	check_eq(node_count(), baseline, "node count stable after 3 round trips")


func test_second_request_during_fade_is_ignored() -> void:
	await start_main()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.1)
	router().call("go_to", &"tavern", &"default")
	await wait(0.8)
	check_eq(level().name, &"AbandonedMine", "first transition wins")
