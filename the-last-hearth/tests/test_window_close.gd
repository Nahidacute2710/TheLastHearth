extends "res://tests/test_case.gd"


func _close_window() -> void:
	main.set("quit_on_close", false)
	main.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	await tree.process_frame


func _saved_state() -> Dictionary:
	return tree.root.get_node("SaveManager").call("read_save")["data"]["game_state"]


func test_closing_in_tavern_saves_including_a_pot_mid_cook() -> void:
	await start_main()
	var state: Node = tree.root.get_node("GameState")
	state.call("add_gold", 9)
	state.get("stash").call("add", load("res://data/items/cave_mushroom.tres"), 2)
	player().global_position = Vector2(520, 110)
	await wait_physics(5)
	await tap(&"interact")
	await _close_window()
	var saved: Dictionary = _saved_state()
	check_eq(int(saved["gold"]), 9, "gold saved on close")
	var stash: Array = saved["stash"]
	check(stash.size() == 1 and stash[0]["id"] == "mushroom_stew", "stew from the pot is saved (%s)" % str(stash))


func test_closing_in_mine_does_not_save() -> void:
	await start_main()
	var state: Node = tree.root.get_node("GameState")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	state.call("add_gold", 50)
	state.get("bag").call("add", load("res://data/items/cave_mushroom.tres"), 3)
	await _close_window()
	check_eq(int(_saved_state()["gold"]), 0, "nothing from the run saved")
	check_eq(int(_saved_state()["day"]), 1, "day not advanced")


func test_closing_on_menu_keeps_save_untouched() -> void:
	await boot_to_menu()
	check(not tree.root.get_node("SaveManager").call("has_save_file"), "no save")
	await _close_window()
	check(not tree.root.get_node("SaveManager").call("has_save_file"), "closing from the menu writes nothing")
