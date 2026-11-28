extends "res://tests/test_case.gd"
## VS-E1: Hearth Flame levels (data, kindling, unlocks, save/load, new game).

const TABLE_PATH: String = "res://data/hearth/hearth_levels.tres"
const COAL_PATH: String = "res://data/items/ember_coal.tres"
const MUSHROOM_PATH: String = "res://data/items/cave_mushroom.tres"
const STEW_PATH: String = "res://data/items/mushroom_stew.tres"


func _state() -> Node:
	return tree.root.get_node("GameState")


func _saves() -> Node:
	return tree.root.get_node("SaveManager")


func _hud() -> Node:
	return main.find_child("HUD", true, false)


func _table() -> HearthTable:
	return load(TABLE_PATH) as HearthTable


func _stash() -> Inventory:
	return _state().get("stash") as Inventory


## Gives exactly what the next level costs.
func _pay_next_level() -> void:
	var next: HearthLevelData = _state().call("get_next_hearth_level")
	_state().call("add_gold", next.gold_cost - int(_state().get("gold")))
	_stash().add(load(COAL_PATH), next.ember_cost - _stash().count_of(load(COAL_PATH)))


func _kindle_to(level: int) -> void:
	while int(_state().get("hearth_level")) < level:
		_pay_next_level()
		_state().call("kindle_hearth")


func test_table_has_five_levels_with_text() -> void:
	var table: HearthTable = _table()
	check_eq(table.max_level(), 5, "5 levels")
	check_eq(table.cost_item, load(COAL_PATH), "paid with Ember Coal")
	check_eq(table.get_level(1).gold_cost + table.get_level(1).ember_cost, 0, "level 1 is free (start)")
	var last_gold: int = 0
	for level: int in range(1, 6):
		var data: HearthLevelData = table.get_level(level)
		check_eq(data.level, level, "level %d numbered" % level)
		check(data.gold_cost >= last_gold, "gold cost does not go down")
		last_gold = data.gold_cost
		check(tr(data.unlock_key) != String(data.unlock_key), "level %d unlock text translated" % level)
		if level >= 2:
			check(data.ember_cost > 0, "level %d costs Ember Coal" % level)
			check(tr(data.letter_key) != String(data.letter_key), "level %d has a letter part" % level)


func test_kindle_reasons_and_payment() -> void:
	var state: Node = _state()
	var coal: Resource = load(COAL_PATH)
	check_eq(state.get("hearth_level"), 1, "starts at level 1")
	check_eq(state.call("get_kindle_block"), &"need_gold", "no gold yet")
	state.call("add_gold", 30)
	check_eq(state.call("get_kindle_block"), &"need_ember", "gold ok, no coal")
	_stash().add(coal, 4)
	check_eq(state.call("get_kindle_block"), &"need_ember", "4 coal is not enough")
	check(not state.call("kindle_hearth"), "cannot kindle without the cost")
	check_eq(state.get("hearth_level"), 1, "still level 1")
	_stash().add(coal, 3)
	var next: HearthLevelData = state.call("get_next_hearth_level")
	var levels: Array[int] = []
	var on_kindled: Callable = func(level: int) -> void: levels.append(level)
	EventBus.hearth_kindled.connect(on_kindled)
	check(state.call("kindle_hearth"), "kindles with enough gold and coal")
	EventBus.hearth_kindled.disconnect(on_kindled)
	check_eq(state.get("hearth_level"), 2, "level 2")
	check_eq(state.get("gold"), 30 - next.gold_cost, "gold paid")
	check_eq(_stash().count_of(coal), 7 - next.ember_cost, "coal taken from the stash")
	check_eq(levels, [2], "hearth_kindled(2) emitted once")
	check_eq(state.get("hearth_letters"), [&"LETTER_HEARTH_2"], "letter part 2 revealed")
	_kindle_to(5)
	check_eq(state.get("hearth_level"), 5, "level 5")
	check_eq(state.call("get_kindle_block"), &"max_level", "max level reached")
	check(not state.call("kindle_hearth", true), "nothing above the max level, even for free")


func test_free_kindle_for_debug_key() -> void:
	var state: Node = _state()
	check(state.call("kindle_hearth", true), "free kindle")
	check_eq(state.get("hearth_level"), 2, "level 2 without paying")
	check_eq(state.get("gold"), 0, "no gold taken")


func test_level_2_cooks_two_stews_faster() -> void:
	await start_main()
	var stove: Node = level().find_child("CookingStation", true, false)
	var mushroom: Resource = load(MUSHROOM_PATH)
	var stew: Resource = load(STEW_PATH)
	_stash().add(mushroom, 4)
	check_eq(stove.call("get_batch_size"), 1, "level 1 cooks one bowl")
	_state().call("kindle_hearth", true)
	check_eq(stove.call("get_batch_size"), 2, "level 2 cooks two bowls")
	stove.get_node("Interactable").call("interact", player())
	check_eq(_stash().count_of(mushroom), 0, "4 mushrooms used")
	var base_time: float = (load("res://data/recipes/mushroom_stew.tres") as RecipeData).cook_time
	await wait(base_time * 0.75)
	check(not stove.call("is_cooking"), "done faster than the level 1 cook time")
	check_eq(_stash().count_of(stew), 2, "2 stews")
	var messages: PackedStringArray = main.find_child("Toast", true, false).call("get_messages")
	check(messages.has("Cooked 2 Mushroom Stew"), "toast says 2 (%s)" % str(messages))
	_stash().add(mushroom, 3)
	check_eq(stove.call("get_batch_size"), 1, "only one bowl with 3 mushrooms")


func test_level_3_opens_a_second_traveler() -> void:
	await start_main()
	var first: Node = level().find_child("WearyTraveler", true, false)
	var second: Node = level().find_child("WearyTraveler2", true, false)
	check(first.call("is_present"), "first traveler at level 1")
	check(not second.call("is_present"), "no second traveler before level 3")
	_state().call("kindle_hearth", true)
	check(not second.call("is_present"), "no second traveler at level 2")
	_state().call("kindle_hearth", true)
	check(second.call("is_present"), "second traveler appears at level 3")
	_stash().add(load(STEW_PATH), 2)
	var gold_before: int = _state().get("gold")
	first.get_node("Interactable").call("interact", player())
	check(not first.call("is_present"), "first traveler served")
	check(second.call("is_present"), "second traveler still waiting")
	second.get_node("Interactable").call("interact", player())
	check(not second.call("is_present"), "second traveler served")
	var payment: int = (load("res://data/customers/weary_traveler.tres") as CustomerData).payment
	check_eq(int(_state().get("gold")) - gold_before, payment * 2, "both paid")
	_state().call("advance_day")
	check(first.call("is_present") and second.call("is_present"), "both come back the next day")


func test_level_4_adds_permanent_health_that_stacks_with_stew() -> void:
	await start_main()
	_state().call("kindle_hearth", true)
	_state().call("kindle_hearth", true)
	check_eq(_hud().get("max_health"), 5, "5 pips before level 4")
	_state().call("kindle_hearth", true)
	check_eq(player().call("get_health").get("max_health"), 6, "6 max health at level 4")
	check_eq(_hud().get("max_health"), 6, "HUD shows 6 pips")
	check_eq(_hud().get("buff_pips"), 0, "none of them are buff pips")
	_stash().add(load(STEW_PATH), 1)
	check(_state().call("eat_from_stash", load(STEW_PATH)), "eat stew")
	check_eq(_hud().get("max_health"), 8, "HUD shows 8 pips with the stew")
	check_eq(_hud().get("buff_pips"), 2, "the last 2 are the stew buff")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	check_eq(player().call("get_health").get("max_health"), 8, "8 max health in the mine")
	check_eq(_hud().get("current_health"), 8, "HUD shows 8 full pips in the mine")
	router().call("go_to", &"tavern", &"cellar_door")
	await wait(0.8)
	check_eq(player().call("get_health").get("max_health"), 6, "back to 6 after the run (bonus stays)")
	check_eq(_hud().get("max_health"), 6, "HUD back to 6")


func test_level_5_dodge_goes_further() -> void:
	await start_main()
	var distances: Array[float] = []
	for i: int in 2:
		if i == 1:
			_kindle_to(5)
			await wait(0.7)
		var body: CharacterBody2D = player()
		body.global_position = Vector2(200, 240)
		body.reset_physics_interpolation()
		await wait_physics(2)
		var start: Vector2 = body.global_position
		body.call("dodge", Vector2.RIGHT)
		await wait(0.3)
		distances.append(body.global_position.x - start.x)
	check(distances[1] > distances[0] * 1.3, "level 5 dodge goes clearly further (%.1f -> %.1f px)" % [distances[0], distances[1]])


func test_save_load_and_new_game_reset() -> void:
	await start_main()
	_kindle_to(4)
	check(_saves().call("save_game"), "save")
	var saved: Dictionary = _saves().call("read_save")["data"]["game_state"]
	check_eq(int(saved["hearth_level"]), 4, "level saved")
	check_eq(saved["hearth_letters"], ["LETTER_HEARTH_2", "LETTER_HEARTH_3", "LETTER_HEARTH_4"], "letters saved")
	main.call("return_to_menu")
	await wait(0.3)
	main.call("start_new_game")
	await wait(0.6)
	check_eq(_state().get("hearth_level"), 1, "new game resets to level 1")
	check_eq((_state().get("hearth_letters") as Array).size(), 0, "new game hides the letter")
	check_eq(_hud().get("max_health"), 5, "HUD back to 5 pips after new game")
	check(not level().find_child("WearyTraveler2", true, false).call("is_present"), "no second traveler after new game")
	# The new game overwrote the save; write the level 4 one back and continue it.
	_state().call("from_dict", saved)
	_saves().call("save_game")
	main.call("return_to_menu")
	await wait(0.3)
	main.call("continue_game")
	await wait(0.6)
	check_eq(_state().get("hearth_level"), 4, "level 4 after Continue")
	check_eq((_state().get("hearth_letters") as Array).size(), 3, "3 letter parts after Continue")
	check_eq(_hud().get("max_health"), 6, "HUD shows 6 pips after Continue")
	check(level().find_child("WearyTraveler2", true, false).call("is_present"), "second traveler after Continue")


func test_old_save_without_hearth_loads_at_level_1() -> void:
	write_save_text(JSON.stringify({
		"save_version": 1, "game_version": "0.1.0", "timestamp": "",
		"game_state": {"day": 3, "gold": 12, "equipped_weapon": "", "stash": [], "customer_served_day": {}},
	}))
	_state().set("hearth_level", 3)
	check_eq(_saves().call("load_game"), 0, "old save loads")
	check_eq(_state().get("hearth_level"), 1, "level 1")
	check_eq((_state().get("hearth_letters") as Array).size(), 0, "no letters")


func test_saved_level_out_of_range_is_clamped_and_letters_follow_level() -> void:
	_state().call("from_dict", {"day": 2, "gold": 0, "equipped_weapon": "", "stash": [], "hearth_level": 99, "hearth_letters": []})
	check_eq(_state().get("hearth_level"), 5, "clamped to the max level")
	check_eq((_state().get("hearth_letters") as Array).size(), 4, "every reached level reveals its letter part")
