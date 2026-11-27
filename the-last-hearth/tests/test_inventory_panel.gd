extends "res://tests/test_case.gd"


func _panel() -> Control:
	return main.find_child("InventoryPanel", true, false) as Control


func _key(keycode: Key) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = keycode
		event.physical_keycode = keycode
		event.pressed = pressed
		Input.parse_input_event(event)
		await tree.process_frame


func after_each() -> void:
	tree.paused = false
	await super.after_each()


func test_inventory_action_toggles_panel_and_pauses_world() -> void:
	await start_main()
	await tap(&"inventory")
	check(_panel().call("is_open"), "inventory opens the panel")
	check(tree.paused, "world is paused while open")
	await tap(&"inventory")
	check(not _panel().call("is_open"), "inventory closes the panel")
	check(not tree.paused, "world resumes")


func test_tab_and_i_keys_toggle_and_tab_does_not_move_focus() -> void:
	await start_main()
	var button: Button = Button.new()
	main.get_node("UILayer").add_child(button)
	var other: Button = Button.new()
	main.get_node("UILayer").add_child(other)
	button.grab_focus()
	await tree.process_frame
	await _key(KEY_TAB)
	check(_panel().call("is_open"), "Tab opens the panel")
	check(button.has_focus(), "Tab did not move GUI focus (TECH-006)")
	await _key(KEY_TAB)
	check(not _panel().call("is_open"), "Tab closes the panel")
	check(button.has_focus(), "focus still unchanged")
	await _key(KEY_I)
	check(_panel().call("is_open"), "I opens the panel")
	await _key(KEY_ESCAPE)
	check(not _panel().call("is_open"), "Esc closes the panel")


func test_panel_shows_bag_and_stash() -> void:
	await start_main()
	var state: Node = tree.root.get_node("GameState")
	var mushroom: Resource = load("res://data/items/cave_mushroom.tres")
	state.get("bag").call("add", mushroom, 3)
	state.get("stash").call("add", mushroom, 25)
	await tap(&"inventory")
	check_eq(_panel().call("get_slot_texts", &"bag"), PackedStringArray(["3"]), "bag slot shows 3")
	check_eq(_panel().call("get_slot_texts", &"stash"), PackedStringArray(["20", "5"]), "stash splits 25 into 20 + 5")
	check_eq(_panel().find_child("BagGrid", true, false).get_child_count(), 12, "bag has 12 slots")
	check_eq(_panel().find_child("StashGrid", true, false).get_child_count(), 30, "stash has 30 slots")
