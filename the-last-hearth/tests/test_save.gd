extends "res://tests/test_case.gd"

const MUSHROOM_PATH: String = "res://data/items/cave_mushroom.tres"
const STEW_PATH: String = "res://data/items/mushroom_stew.tres"


func _saves() -> Node:
	return tree.root.get_node("SaveManager")


func _state() -> Node:
	return tree.root.get_node("GameState")


func test_item_db_lists_every_item_file() -> void:
	var paths: Dictionary = (load("res://scripts/data/item_db.gd") as GDScript).get("ITEM_PATHS")
	for file_name: String in DirAccess.get_files_at("res://data/items/"):
		if not file_name.ends_with(".tres"):
			continue
		var item: Resource = load("res://data/items/" + file_name)
		check(paths.has(item.get("id")), "%s is registered in ItemDB" % file_name)
		check_eq(paths.get(item.get("id")), "res://data/items/" + file_name, "ItemDB path for %s" % file_name)


func test_save_and_load_round_trip() -> void:
	var state: Node = _state()
	state.call("equip_weapon", load("res://data/items/rusty_pickaxe.tres"))
	state.get("stash").call("add", load(MUSHROOM_PATH), 23)
	state.get("stash").call("add", load(STEW_PATH), 2)
	state.set("day", 4)
	state.call("add_gold", 37)
	state.call("mark_customer_served", &"weary_traveler")
	TranslationServer.set_locale("vi")
	check(_saves().call("save_game"), "save succeeds")
	check(not FileAccess.file_exists(_saves().call("get_save_path") + ".tmp"), "no .tmp left behind")
	state.call("reset_session")
	TranslationServer.set_locale("en")
	check_eq(_saves().call("load_game"), 0, "load returns OK")
	check_eq(state.get("day"), 4, "day restored")
	check_eq(state.get("gold"), 37, "gold restored")
	check_eq(state.get("equipped_weapon"), load("res://data/items/rusty_pickaxe.tres"), "weapon restored")
	check_eq(state.get("stash").call("count_of", load(MUSHROOM_PATH)), 23, "stash mushrooms restored")
	check_eq(state.get("stash").call("count_of", load(STEW_PATH)), 2, "stash stew restored")
	check(state.call("is_customer_served_today", &"weary_traveler"), "served customer restored")
	check(TranslationServer.get_locale().begins_with("vi"), "locale restored")


func test_corrupt_save_is_backed_up_and_reported() -> void:
	write_save_text("{ this is not json")
	check(not _saves().call("check_save"), "corrupt save is not offered")
	check_eq(_saves().get("last_error_key"), &"MENU_ERROR_SAVE_CORRUPT", "error key set")
	check(FileAccess.file_exists(_saves().call("get_backup_path")), ".bak kept")
	check(not _saves().call("has_save_file"), "bad save moved away")


func test_empty_save_is_corrupt() -> void:
	write_save_text("")
	check(not _saves().call("check_save"), "empty save is not offered")
	check_eq(_saves().get("last_error_key"), &"MENU_ERROR_SAVE_CORRUPT", "empty file reported as corrupt")
	check(FileAccess.file_exists(_saves().call("get_backup_path")), ".bak kept")


func test_missing_fields_are_corrupt_and_not_applied() -> void:
	_state().set("day", 3)
	write_save_text(JSON.stringify({"save_version": 1, "game_state": {"day": 9, "gold": 5}}))
	check_eq(_saves().call("load_game"), 2, "load reports CORRUPT")
	check_eq(_state().get("day"), 3, "nothing applied from a bad save")
	check(not _saves().call("check_save"), "not offered")
	check(FileAccess.file_exists(_saves().call("get_backup_path")), ".bak kept")


func test_unknown_version_is_reported() -> void:
	write_save_text(JSON.stringify({"save_version": 99, "game_state": {"day": 1, "gold": 0, "equipped_weapon": "", "stash": []}}))
	check(not _saves().call("check_save"), "unknown version is not offered")
	check_eq(_saves().get("last_error_key"), &"MENU_ERROR_SAVE_VERSION", "version error key")


func test_autosave_on_return_from_mine_and_after_serving_not_in_mine() -> void:
	await start_main()
	var state: Node = _state()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	_saves().call("delete_save")
	state.get("bag").call("add", load(MUSHROOM_PATH), 3)
	tree.root.get_node("EventBus").emit_signal("autosave_requested")
	check(not _saves().call("has_save_file"), "no autosave while in the mine")
	router().call("go_to", &"tavern", &"cellar_door")
	await wait(0.8)
	check(_saves().call("has_save_file"), "autosave after returning to the tavern")
	var saved: Dictionary = _saves().call("read_save")["data"]
	check_eq(int(saved["game_state"]["day"]), 2, "saved after the day advanced")
	check_eq((saved["game_state"]["stash"] as Array).size(), 1, "saved after storing the bag")
	state.get("stash").call("add", load(STEW_PATH), 1)
	player().global_position = Vector2(430, 340)
	await wait_physics(5)
	await tap(&"interact")
	saved = _saves().call("read_save")["data"]
	check_eq(int(saved["game_state"]["gold"]), 15, "autosave after serving the traveler")


func test_stove_refuses_when_stash_has_no_room_for_the_dish() -> void:
	await start_main()
	var stash: RefCounted = _state().get("stash")
	var mushroom: Resource = load(MUSHROOM_PATH)
	var filler: Resource = load("res://data/items/rusty_pickaxe.tres")
	stash.call("add", mushroom, 2)
	for i: int in 29:
		stash.call("add", filler, 1)
	player().global_position = Vector2(520, 110)
	await wait_physics(5)
	await tap(&"interact")
	var stove: Node = level().find_child("CookingStation", true, false)
	check(not stove.call("is_cooking"), "does not cook with a full stash")
	check_eq(stash.call("count_of", mushroom), 2, "ingredients are kept")
	var messages: PackedStringArray = main.find_child("Toast", true, false).call("get_messages")
	check(messages.has("The stash is full"), "stash full message (%s)" % str(messages))


func test_dish_is_never_lost_when_stash_fills_during_cooking() -> void:
	await start_main()
	var stash: RefCounted = _state().get("stash")
	stash.call("add", load(MUSHROOM_PATH), 2)
	player().global_position = Vector2(520, 110)
	await wait_physics(5)
	await tap(&"interact")
	var filler: Resource = load("res://data/items/rusty_pickaxe.tres")
	while stash.call("add", filler, 1) == 0:
		pass
	await wait(1.7)
	check_eq(stash.call("count_of", load(STEW_PATH)), 1, "the stew is still added")
