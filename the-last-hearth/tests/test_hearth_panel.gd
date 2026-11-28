extends "res://tests/test_case.gd"
## VS-E1: the fireplace in the tavern, the Hearth panel, kindle feedback and the letter.

const COAL_PATH: String = "res://data/items/ember_coal.tres"


func _state() -> Node:
	return tree.root.get_node("GameState")


func _panel() -> Node:
	return main.find_child("HearthPanel", true, false)


func _hearth() -> Node:
	return level().find_child("HearthFlame", true, false)


func _open_from_fireplace() -> void:
	_hearth().get_node("Interactable").call("interact", player())
	await tree.process_frame


func test_panel_shows_cost_and_why_it_cannot_kindle() -> void:
	await start_main()
	check(_hearth() != null, "the tavern has the Hearth fireplace")
	await _open_from_fireplace()
	check(_panel().call("is_open"), "interacting opens the panel")
	check(tree.paused, "the world is paused")
	check_eq(_panel().call("get_level_text"), "Level 1 / 5", "level text")
	check_eq(_panel().call("get_unlock_text"), "Unlocks: The stove cooks 2 dishes at once, faster", "unlock text")
	check_eq(_panel().call("get_gold_text"), "Gold: 0 / 30", "gold have / need")
	check_eq(_panel().call("get_ember_text"), "Ember Coal in stash: 0 / 5", "coal have / need")
	check(not _panel().call("is_kindle_enabled"), "Kindle disabled")
	check_eq(_panel().call("get_block_text"), "Not enough gold", "reason: gold")
	check_eq(_panel().call("get_letter_texts"), PackedStringArray(["Kindle the fire to read more of the letter."]), "letter hint")
	_state().call("add_gold", 40)
	check_eq(_panel().call("get_block_text"), "Not enough Ember Coal in the stash", "reason: coal")
	await tap(&"pause")
	check(not _panel().call("is_open"), "Esc closes the panel")
	check(not tree.paused, "world resumes")
	check(not main.find_child("PauseMenu", true, false).visible, "Esc did not open the pause menu")


func test_kindling_from_the_panel() -> void:
	await start_main()
	var coal: Resource = load(COAL_PATH)
	_state().call("add_gold", 35)
	(_state().get("stash") as Inventory).add(coal, 7)
	var scale_before: float = _hearth().call("get_flame_scale")
	var light_before: float = _hearth().call("get_light_energy")
	await _open_from_fireplace()
	check(_panel().call("is_kindle_enabled"), "Kindle enabled with 35 gold and 7 coal")
	check_eq(_panel().call("get_block_text"), "", "no reason shown")
	var played: Array[StringName] = main.find_child("Audio", true, false).get("played")
	played.clear()
	_panel().call("press_kindle")
	check_eq(_state().get("hearth_level"), 2, "level 2")
	check_eq(_state().get("gold"), 5, "30 gold paid")
	check_eq((_state().get("stash") as Inventory).count_of(coal), 2, "5 coal taken from the stash")
	check_eq(_panel().call("get_level_text"), "Level 2 / 5", "panel shows level 2")
	check_eq(_panel().call("get_ember_text"), "Ember Coal in stash: 2 / 10", "next cost shown")
	check(played.has(&"hearth_kindle"), "kindle sound")
	var letters: PackedStringArray = _panel().call("get_letter_texts")
	check_eq(letters.size(), 1, "one letter part")
	check(letters[0].begins_with("Maren."), "the first part of the letter is shown (%s)" % letters[0])
	check(_hearth().call("get_flame_scale") > scale_before, "the fire is bigger")
	check(_hearth().call("get_light_energy") > light_before, "the light is brighter")
	await tap(&"pause")
	await wait(0.1)
	var messages: PackedStringArray = main.find_child("Toast", true, false).call("get_messages")
	check(messages.has("The Hearth reached level 2: The stove cooks 2 dishes at once, faster"), "toast (%s)" % str(messages))
	check(int(tree.root.get_node("SaveManager").call("read_save")["data"]["game_state"]["hearth_level"]) == 2, "kindling autosaves")


func test_max_level_and_rereading_the_letter() -> void:
	await start_main()
	for i: int in 4:
		_state().call("kindle_hearth", true)
	await _open_from_fireplace()
	check(_panel().call("is_max_level_shown"), "max level message")
	check(not _panel().call("is_kindle_enabled"), "no Kindle at max")
	check_eq(_panel().call("get_gold_text"), "", "no cost at max")
	check_eq((_panel().call("get_letter_texts") as PackedStringArray).size(), 4, "all 4 letter parts can be read again")
	await tap(&"pause")


func test_panel_in_vietnamese_and_after_new_game_and_continue() -> void:
	await start_main()
	_state().call("kindle_hearth", true)
	_state().call("kindle_hearth", true)
	tree.root.get_node("SaveManager").call("save_game")
	var saved: Dictionary = tree.root.get_node("SaveManager").call("read_save")["data"]["game_state"]
	tree.root.get_node("SaveManager").call("set_locale", "vi")
	await _open_from_fireplace()
	check_eq(_panel().call("get_level_text"), "Cấp 3 / 5", "Vietnamese level text")
	check_eq(_panel().call("get_gold_text"), "Vàng: 0 / 150", "Vietnamese gold text")
	check_eq((_panel().call("get_letter_texts") as PackedStringArray).size(), 2, "2 letter parts")
	check((_panel().call("get_letter_texts") as PackedStringArray)[0].begins_with("Maren. Nếu lửa"), "Vietnamese letter")
	await tap(&"pause")
	main.call("return_to_menu")
	await wait(0.3)
	main.call("start_new_game")
	await wait(0.6)
	await _open_from_fireplace()
	check_eq(_panel().call("get_level_text"), "Cấp 1 / 5", "new game: level 1 in the panel")
	check_eq((_panel().call("get_letter_texts") as PackedStringArray).size(), 1, "new game: only the hint")
	check(is_equal_approx(_hearth().call("get_flame_scale"), 0.55), "new game: small fire")
	await tap(&"pause")
	_state().call("from_dict", saved)
	tree.root.get_node("SaveManager").call("save_game")
	main.call("return_to_menu")
	await wait(0.3)
	main.call("continue_game")
	await wait(0.6)
	await _open_from_fireplace()
	check_eq(_panel().call("get_level_text"), "Cấp 3 / 5", "Continue: level 3 in the panel")
	check_eq((_panel().call("get_letter_texts") as PackedStringArray).size(), 2, "Continue: 2 letter parts")
	check(is_equal_approx(_hearth().call("get_flame_scale"), 0.85), "Continue: level 3 fire")
	await tap(&"pause")
