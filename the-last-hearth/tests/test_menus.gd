extends "res://tests/test_case.gd"


func _saves() -> Node:
	return tree.root.get_node("SaveManager")


func _menu() -> Node:
	return main.find_child("MainMenu", true, false)


func _pause() -> Node:
	return main.find_child("PauseMenu", true, false)


func _button(node_name: String) -> Button:
	return _menu().find_child(node_name, true, false) as Button


func _save_with_day(day: int) -> void:
	var state: Node = tree.root.get_node("GameState")
	state.call("reset_session")
	state.set("day", day)
	_saves().call("save_game")
	state.call("reset_session")


func _key(keycode: Key) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = keycode
		event.physical_keycode = keycode
		event.pressed = pressed
		Input.parse_input_event(event)
		await tree.process_frame


func test_boot_without_save_shows_menu_without_continue() -> void:
	await boot_to_menu()
	check(_menu().call("is_open"), "main menu is shown at boot")
	check(level() == null, "no level loaded behind the menu")
	check(not _button("ContinueButton").visible, "Continue hidden without a save")
	check(_button("NewGameButton").visible and _button("QuitButton").visible, "New Game and Quit shown")
	_button("NewGameButton").pressed.emit()
	await wait(0.4)
	check(not _menu().call("is_open"), "menu closes")
	check_eq(level().name, &"TavernMainHall", "new game starts in the tavern")
	check(_saves().call("has_save_file"), "new game writes a save")


func test_continue_loads_the_save() -> void:
	_save_with_day(5)
	await boot_to_menu()
	check(_button("ContinueButton").visible, "Continue shown with a valid save")
	_button("ContinueButton").pressed.emit()
	await wait(0.4)
	check_eq(level().name, &"TavernMainHall", "continue enters the tavern")
	check_eq(tree.root.get_node("GameState").get("day"), 5, "day comes from the save")


func test_corrupt_save_shows_error_and_allows_new_game() -> void:
	write_save_text("{ broken")
	await boot_to_menu()
	var error: Label = _menu().find_child("ErrorLabel", true, false) as Label
	check(error.visible, "error line visible")
	check_eq(error.text, "MENU_ERROR_SAVE_CORRUPT", "error uses the translation key")
	check(not _button("ContinueButton").visible, "no Continue for a corrupt save")
	check(FileAccess.file_exists(_saves().call("get_backup_path")), ".bak kept")
	_button("NewGameButton").pressed.emit()
	await wait(0.4)
	check(level() != null, "new game works after a corrupt save")


func test_new_game_over_existing_save_asks_first() -> void:
	_save_with_day(7)
	await boot_to_menu()
	_button("NewGameButton").pressed.emit()
	check(_menu().call("is_confirm_open"), "asks before overwriting")
	check(level() == null, "nothing started yet")
	_button("ConfirmNo").pressed.emit()
	check(not _menu().call("is_confirm_open"), "No closes the question")
	check_eq(int(_saves().call("read_save")["data"]["game_state"]["day"]), 7, "save untouched after No")
	_button("NewGameButton").pressed.emit()
	_button("ConfirmYes").pressed.emit()
	await wait(0.4)
	check(level() != null, "Yes starts the new game")
	check_eq(int(_saves().call("read_save")["data"]["game_state"]["day"]), 1, "save overwritten with day 1")


func test_esc_pauses_and_resumes() -> void:
	await start_main()
	await _key(KEY_ESCAPE)
	check(_pause().call("is_open"), "Esc opens the pause menu")
	check(tree.paused, "game paused")
	await _key(KEY_ESCAPE)
	check(not _pause().call("is_open"), "Esc again resumes")
	check(not tree.paused, "game resumed")


func test_esc_closes_inventory_first() -> void:
	await start_main()
	await tap(&"inventory")
	var panel: Node = main.find_child("InventoryPanel", true, false)
	check(panel.call("is_open"), "inventory open")
	await _key(KEY_ESCAPE)
	check(not panel.call("is_open"), "first Esc closes the inventory")
	check(not _pause().call("is_open"), "pause menu not opened by the same Esc")
	await _key(KEY_ESCAPE)
	check(_pause().call("is_open"), "second Esc opens the pause menu")
	await tap(&"inventory")
	check(not panel.call("is_open"), "inventory cannot open over the pause menu")


func test_main_menu_from_mine_does_not_save() -> void:
	await start_main()
	var state: Node = tree.root.get_node("GameState")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	state.call("add_gold", 99)
	_pause().call("open")
	(_pause().find_child("MainMenuButton", true, false) as Button).pressed.emit()
	await tree.process_frame
	check(_menu().call("is_open"), "back on the main menu")
	check(level() == null, "level unloaded")
	check(not tree.paused, "not paused on the menu")
	check_eq(int(_saves().call("read_save")["data"]["game_state"]["gold"]), 0, "nothing from the mine run was saved")
	_button("ContinueButton").pressed.emit()
	await wait(0.4)
	check_eq(state.get("gold"), 0, "continue restores the last save")
	check_eq(state.get("day"), 1, "day did not advance")


func test_main_menu_from_tavern_saves() -> void:
	await start_main()
	tree.root.get_node("GameState").call("add_gold", 12)
	_pause().call("open")
	(_pause().find_child("MainMenuButton", true, false) as Button).pressed.emit()
	await tree.process_frame
	check_eq(int(_saves().call("read_save")["data"]["game_state"]["gold"]), 12, "leaving from the tavern saves")


func test_inventory_slot_shows_item_name() -> void:
	await start_main()
	tree.root.get_node("GameState").get("stash").call("add", load("res://data/items/cave_mushroom.tres"), 3)
	await tap(&"inventory")
	var panel: Node = main.find_child("InventoryPanel", true, false)
	check_eq(panel.call("get_item_name_text"), "", "no name before hovering")
	panel.call("hover_slot", &"stash", 0)
	check_eq(panel.call("get_item_name_text"), "Cave Mushroom", "hover shows the name")
	panel.call("hover_slot", &"stash", 5)
	check_eq(panel.call("get_item_name_text"), "", "empty slot shows nothing")
	TranslationServer.set_locale("vi")
	panel.call("select_slot", &"stash", 0)
	check_eq(panel.call("get_item_name_text"), "Nấm Hang", "selected name is translated")
