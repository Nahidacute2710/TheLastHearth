extends "res://tests/test_case.gd"
## Same-session checks (no restart): New Game and Continue after returning to the main menu
## must replace the whole in-memory state, and the HUD must show it.

const MUSHROOM_PATH: String = "res://data/items/cave_mushroom.tres"
const STEW_PATH: String = "res://data/items/mushroom_stew.tres"
const RACK_POS: Vector2 = Vector2(736, 386)


func _state() -> Node:
	return tree.root.get_node("GameState")


func _saves() -> Node:
	return tree.root.get_node("SaveManager")


func _menu() -> Node:
	return main.find_child("MainMenu", true, false)


func _display() -> Node:
	return main.find_child("DayGoldDisplay", true, false)


func _hud() -> Node:
	return main.find_child("HUD", true, false)


func _press(node: Node, button_name: String) -> void:
	(node.find_child(button_name, true, false) as Button).pressed.emit()


func _back_to_menu() -> void:
	var pause: Node = main.find_child("PauseMenu", true, false)
	pause.call("open")
	_press(pause, "MainMenuButton")
	await tree.process_frame


## Plays a bit: takes the pickaxe, serves the traveler, fills bag and stash, reaches day 3 with gold.
func _play_a_while() -> void:
	var state: Node = _state()
	player().global_position = RACK_POS
	await wait_physics(5)
	await tap(&"interact")
	state.get("stash").call("add", load(STEW_PATH), 1)
	player().global_position = Vector2(430, 340)
	await wait_physics(5)
	await tap(&"interact")
	state.get("stash").call("add", load(MUSHROOM_PATH), 7)
	state.call("advance_day")
	state.call("advance_day")
	state.call("add_gold", 40)
	state.get("bag").call("add", load(MUSHROOM_PATH), 2)


func test_new_game_after_playing_resets_everything() -> void:
	await start_main()
	TranslationServer.set_locale("vi")
	await _play_a_while()
	var state: Node = _state()
	check(state.get("equipped_weapon") != null and state.get("gold") == 55 and state.get("day") == 3, "precondition: played state")
	await _back_to_menu()
	_press(_menu(), "NewGameButton")
	check(_menu().call("is_confirm_open"), "asks before overwriting")
	_press(_menu(), "ConfirmYes")
	await wait(0.4)
	check_eq(state.get("day"), 1, "day reset")
	check_eq(state.get("gold"), 0, "gold reset")
	check(state.get("bag").call("is_empty"), "bag reset")
	check(state.get("stash").call("is_empty"), "stash reset")
	check(state.get("equipped_weapon") == null, "equipped weapon reset")
	check(not state.call("owns_item_id", &"rusty_pickaxe"), "pickaxe no longer owned")
	check((state.get("customer_served_day") as Dictionary).is_empty(), "served customers reset")
	var rack: Node = level().find_child("WeaponRack", true, false)
	check(rack.get_node("WeaponSprite").get("visible"), "rack shows the pickaxe again")
	check(rack.get_node("Interactable").get("enabled"), "pickaxe can be taken again")
	check(level().find_child("WearyTraveler", true, false).call("is_present"), "traveler is back")
	check_eq(_display().call("get_day_text"), "Ngày 1", "HUD day reset (locale kept)")
	check_eq(_display().call("get_gold_text"), "0 vàng", "HUD gold reset")
	check_eq(_hud().call("get_item_count_text"), "×0", "HUD mushroom count reset")
	check(TranslationServer.get_locale().begins_with("vi"), "locale is not reset")
	var saved: Dictionary = _saves().call("read_save")["data"]["game_state"]
	check_eq(int(saved["day"]), 1, "save is day 1")
	check_eq(int(saved["gold"]), 0, "save has 0 gold")
	check_eq((saved["stash"] as Array).size(), 0, "save has an empty stash")
	check_eq(saved["equipped_weapon"], "", "save has no weapon")
	check_eq((saved["customer_served_day"] as Dictionary).size(), 0, "save has no served customers")


func test_continue_after_menu_replaces_state_with_the_save() -> void:
	await start_main()
	var state: Node = _state()
	state.call("equip_weapon", load("res://data/items/rusty_pickaxe.tres"))
	state.get("stash").call("add", load(MUSHROOM_PATH), 3)
	state.call("add_gold", 15)
	state.call("advance_day")
	_saves().call("save_game")
	# Keep playing without saving: these must not survive Continue.
	state.call("add_gold", 50)
	state.get("stash").call("add", load(STEW_PATH), 2)
	state.call("advance_day")
	state.call("mark_customer_served", &"weary_traveler")
	_saves().call("save_game")
	state.call("advance_day")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	state.get("bag").call("add", load(MUSHROOM_PATH), 4)
	state.call("add_gold", 100)
	await _back_to_menu()
	_press(_menu(), "ContinueButton")
	await wait(0.4)
	check_eq(level().name, &"TavernMainHall", "continue enters the tavern")
	check_eq(state.get("day"), 3, "day from the save")
	check_eq(state.get("gold"), 65, "gold from the save, not the unsaved run")
	check(state.get("bag").call("is_empty"), "bag from the unsaved run is gone")
	check_eq(state.get("stash").call("count_of", load(MUSHROOM_PATH)), 3, "stash mushrooms from the save")
	check_eq(state.get("stash").call("count_of", load(STEW_PATH)), 2, "stash stew from the save")
	check(state.call("is_customer_served_today", &"weary_traveler"), "served-today flag comes from the save")
	check_eq(_display().call("get_day_text"), "Day 3", "HUD day matches the save")
	check_eq(_display().call("get_gold_text"), "65 gold", "HUD gold matches the save")
	check_eq(_hud().call("get_item_count_text"), "×0", "HUD bag count matches")
	check(not level().find_child("WeaponRack", true, false).get_node("Interactable").get("enabled"), "rack empty: saved weapon equipped")


func test_continue_after_new_game_in_same_session() -> void:
	await start_main()
	_state().call("add_gold", 20)
	_saves().call("save_game")
	await _back_to_menu()
	_press(_menu(), "NewGameButton")
	_press(_menu(), "ConfirmYes")
	await wait(0.4)
	await _back_to_menu()
	_press(_menu(), "ContinueButton")
	await wait(0.4)
	check_eq(_state().get("gold"), 0, "continue loads the new game's save")
	check_eq(_display().call("get_gold_text"), "0 gold", "HUD agrees")


func test_menu_from_tavern_mid_cook_keeps_the_dish_in_the_save() -> void:
	await start_main()
	_state().get("stash").call("add", load(MUSHROOM_PATH), 2)
	player().global_position = Vector2(520, 110)
	await wait_physics(5)
	await tap(&"interact")
	check(level().find_child("CookingStation", true, false).call("is_cooking"), "cooking started")
	await _back_to_menu()
	var stash: Array = _saves().call("read_save")["data"]["game_state"]["stash"]
	check(stash.size() == 1 and stash[0]["id"] == "mushroom_stew", "save has the stew, not lost mushrooms (%s)" % str(stash))
