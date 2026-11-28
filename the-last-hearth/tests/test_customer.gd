extends "res://tests/test_case.gd"

const TRAVELER_POS: Vector2 = Vector2(430, 340)


func _state() -> Node:
	return tree.root.get_node("GameState")


func _traveler() -> Node:
	return level().find_child("WearyTraveler", true, false)


func _display() -> Node:
	return main.find_child("DayGoldDisplay", true, false)


func _messages() -> PackedStringArray:
	return main.find_child("Toast", true, false).call("get_messages")


func test_traveler_waits_without_stew() -> void:
	await start_main()
	check(_traveler().call("is_present"), "traveler is in the tavern on day 1")
	player().global_position = TRAVELER_POS
	await wait_physics(5)
	await tap(&"interact")
	check(_traveler().call("is_present"), "traveler keeps waiting")
	check(_messages().has("Weary Traveler is waiting for Mushroom Stew"), "waiting message (%s)" % str(_messages()))
	check_eq(_state().get("gold"), 0, "no gold")


func test_serving_stew_pays_gold_and_traveler_returns_next_day() -> void:
	await start_main()
	var stew: Resource = load("res://data/items/mushroom_stew.tres")
	_state().get("stash").call("add", stew, 2)
	check_eq(_display().call("get_day_text"), "Day 1", "HUD shows day 1")
	check_eq(_display().call("get_gold_text"), "0 gold", "HUD shows 0 gold")
	player().global_position = TRAVELER_POS
	await wait_physics(5)
	await tap(&"interact")
	check_eq(_state().get("gold"), 30, "traveler pays 30 gold")
	check_eq(_state().get("stash").call("count_of", stew), 1, "one stew taken from the stash")
	check(not _traveler().call("is_present"), "traveler leaves after being served")
	check_eq(_display().call("get_gold_text"), "30 gold", "HUD gold updates")
	check(_messages().has("Weary Traveler paid 30 gold"), "payment message")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	router().call("go_to", &"tavern", &"cellar_door")
	await wait(0.8)
	check(_traveler().call("is_present"), "traveler is back the next day")
	check_eq(_display().call("get_day_text"), "Day 2", "HUD shows day 2")
	check_eq(_state().get("gold"), 30, "gold is kept")


func test_traveler_does_not_return_on_same_day() -> void:
	await start_main()
	_state().call("mark_customer_served", &"weary_traveler")
	router().call("go_to", &"tavern", &"default")
	await wait(0.8)
	check(not _traveler().call("is_present"), "already served today, so not present after reloading the tavern")
	_state().call("advance_day")
	check(_traveler().call("is_present"), "a new day brings the traveler back")


func test_day_and_gold_text_follow_locale() -> void:
	await start_main()
	TranslationServer.set_locale("vi")
	await tree.process_frame
	check_eq(_display().call("get_day_text"), "Ngày 1", "Vietnamese day text")
	check_eq(_display().call("get_gold_text"), "0 vàng", "Vietnamese gold text")
