extends "res://tests/test_case.gd"

const STOVE_POS: Vector2 = Vector2(520, 110)


func _stash() -> RefCounted:
	return tree.root.get_node("GameState").get("stash")


func _stove() -> Node:
	return level().find_child("CookingStation", true, false)


func _toast_messages() -> PackedStringArray:
	return main.find_child("Toast", true, false).call("get_messages")


func test_cooking_without_mushrooms_shows_message() -> void:
	await start_main()
	player().global_position = STOVE_POS
	await wait_physics(5)
	await tap(&"interact")
	check(not _stove().call("is_cooking"), "does not cook without ingredients")
	check(_toast_messages().has("Need 2 Cave Mushroom in the stash"), "tells what is missing (%s)" % str(_toast_messages()))


func test_cooks_stew_from_stash_with_progress() -> void:
	await start_main()
	var mushroom: Resource = load("res://data/items/cave_mushroom.tres")
	var stew: Resource = load("res://data/items/mushroom_stew.tres")
	_stash().call("add", mushroom, 3)
	tree.root.get_node("GameState").get("bag").call("add", mushroom, 5)
	player().global_position = STOVE_POS
	await wait_physics(5)
	await tap(&"interact")
	check(_stove().call("is_cooking"), "cooking starts")
	check_eq(_stash().call("count_of", mushroom), 1, "2 mushrooms taken from the stash")
	check_eq(tree.root.get_node("GameState").get("bag").call("count_of", mushroom), 5, "the bag is not used")
	await wait(0.75)
	var progress: float = _stove().call("get_progress")
	check(progress > 0.3 and progress < 0.8, "progress is around half (%.2f)" % progress)
	check_eq(_stash().call("count_of", stew), 0, "no stew yet")
	await tap(&"interact")
	check_eq(_stash().call("count_of", mushroom), 1, "cannot start a second pot while cooking")
	await wait(1.0)
	check(not _stove().call("is_cooking"), "cooking done")
	check_eq(_stash().call("count_of", stew), 1, "stew is in the stash")
	check(_toast_messages().has("Cooked Mushroom Stew"), "toast says the dish is ready")


func test_leaving_mid_cook_still_gives_the_dish() -> void:
	await start_main()
	var stew: Resource = load("res://data/items/mushroom_stew.tres")
	_stash().call("add", load("res://data/items/cave_mushroom.tres"), 2)
	player().global_position = STOVE_POS
	await wait_physics(5)
	await tap(&"interact")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	check_eq(_stash().call("count_of", stew), 1, "dish finished when the tavern unloads")
