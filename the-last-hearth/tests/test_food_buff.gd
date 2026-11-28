extends "res://tests/test_case.gd"

const STEW_PATH: String = "res://data/items/mushroom_stew.tres"


func _state() -> Node:
	return tree.root.get_node("GameState")


func _hud() -> Node:
	return main.find_child("HUD", true, false)


func _panel() -> Node:
	return main.find_child("InventoryPanel", true, false)


## Opens the inventory, selects stash slot 0 (the stew) and presses Eat.
func _eat_stew_from_panel() -> void:
	await tap(&"inventory")
	_panel().call("select_slot", &"stash", 0)
	_panel().call("press_eat_button")
	await tap(&"inventory")


func test_eating_stew_gives_two_extra_pips_for_the_next_run() -> void:
	await start_main()
	var stew: Resource = load(STEW_PATH)
	_state().get("stash").call("add", stew, 2)
	await tap(&"inventory")
	_panel().call("select_slot", &"stash", 0)
	check(_panel().call("is_eat_button_enabled"), "Eat button enabled for stew in the tavern")
	check_eq(_panel().call("get_eat_button_text"), "Eat (+2 max health next run)", "Eat button text")
	_panel().call("press_eat_button")
	check_eq(_state().get("stash").call("count_of", stew), 1, "one stew eaten from the stash")
	check_eq(_state().get("max_health_buff"), 2, "buff stored")
	check(not _panel().call("is_eat_button_enabled"), "cannot eat a second time this run")
	check_eq(_panel().call("get_eat_button_text"), "Already ate this run", "button says why")
	await tap(&"inventory")
	var messages: PackedStringArray = main.find_child("Toast", true, false).call("get_messages")
	check(messages.has("Ate Mushroom Stew: +2 max health next run"), "toast (%s)" % str(messages))
	check_eq(_hud().get("max_health"), 7, "HUD shows 7 pips")
	check_eq(_hud().get("buff_pips"), 2, "2 of them are buff pips")
	check_eq(int(tree.root.get_node("SaveManager").call("read_save")["data"]["game_state"]["max_health_buff"]), 2, "eating autosaves the buff")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	check_eq(player().call("get_health").get("max_health"), 7, "7 max health in the mine")
	check_eq(player().call("get_health").get("current_health"), 7, "starts the run at 7")
	check_eq(_hud().get("current_health"), 7, "HUD in the mine shows 7")
	router().call("go_to", &"tavern", &"cellar_door")
	await wait(0.8)
	check_eq(_state().get("max_health_buff"), 0, "buff gone after returning")
	check_eq(player().call("get_health").get("max_health"), 5, "back to 5 max health")
	check_eq(_hud().get("max_health"), 5, "HUD back to 5 pips")
	check_eq(_hud().get("buff_pips"), 0, "no buff pips")
	await tap(&"inventory")
	_panel().call("select_slot", &"stash", 0)
	check(_panel().call("is_eat_button_enabled"), "can eat again for the next run")


func test_buff_is_lost_on_death() -> void:
	await start_main()
	_state().get("stash").call("add", load(STEW_PATH), 1)
	await _eat_stew_from_panel()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	player().call("get_health").call("take_damage", 99)
	await wait(1.4)
	check_eq(level().name, &"TavernMainHall", "woke up in the tavern")
	check_eq(_state().get("max_health_buff"), 0, "buff lost on death")
	check_eq(_hud().get("max_health"), 5, "HUD shows 5 pips")
	check_eq(_hud().get("current_health"), 5, "full base health")


func test_cannot_eat_in_the_mine() -> void:
	await start_main()
	_state().get("stash").call("add", load(STEW_PATH), 1)
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	await tap(&"inventory")
	_panel().call("select_slot", &"stash", 0)
	check(_panel().call("is_eat_button_visible"), "button visible for food")
	check(not _panel().call("is_eat_button_enabled"), "but disabled in the mine")
	check_eq(_panel().call("get_eat_button_text"), "Eat in the tavern", "reason shown")
	check(not _state().call("eat_from_stash", load(STEW_PATH)), "GameState refuses too")


func test_no_eat_button_for_mushrooms_or_bag() -> void:
	await start_main()
	_state().get("stash").call("add", load("res://data/items/cave_mushroom.tres"), 2)
	_state().get("bag").call("add", load(STEW_PATH), 1)
	await tap(&"inventory")
	_panel().call("select_slot", &"stash", 0)
	check(not _panel().call("is_eat_button_visible"), "mushrooms are not food")
	_panel().call("select_slot", &"bag", 0)
	check(not _panel().call("is_eat_button_visible"), "only food in the stash can be eaten")


func test_buff_survives_save_and_continue() -> void:
	await start_main()
	_state().get("stash").call("add", load(STEW_PATH), 1)
	await _eat_stew_from_panel()
	var pause: Node = main.find_child("PauseMenu", true, false)
	pause.call("open")
	(pause.find_child("MainMenuButton", true, false) as Button).pressed.emit()
	await tree.process_frame
	_state().call("start_new_game")
	(main.find_child("ContinueButton", true, false) as Button).pressed.emit()
	await wait(0.4)
	check_eq(_state().get("max_health_buff"), 2, "buff loaded")
	check_eq(_hud().get("max_health"), 7, "HUD shows the buff after Continue")
	check_eq(_hud().get("buff_pips"), 2, "buff pips after Continue")
