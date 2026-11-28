extends "res://tests/test_case.gd"
## VSA2: settings.cfg (language, volumes, fullscreen, keys) apart from the game save.

const OLD_SAVE: String = """{
	"save_version": 1,
	"game_version": "0.1.0",
	"timestamp": "2026-11-28T10:00:00",
	"game_state": {"day": 3, "gold": 12, "equipped_weapon": "", "stash": [], "customer_served_day": {}},
	"settings": {"locale": "vi"}
}"""


func _saves() -> Node:
	return tree.root.get_node("SaveManager")


func _settings() -> GameSettings:
	return _saves().get("settings") as GameSettings


func _display() -> Node:
	return main.find_child("DayGoldDisplay", true, false)


func _key_event(keycode: Key) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = keycode
	return event


func _bound_to(action: StringName, keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == keycode:
			return true
	return false


func _write_settings_text(text: String) -> void:
	DirAccess.make_dir_recursive_absolute(TEST_SAVE_DIR)
	var file: FileAccess = FileAccess.open(_saves().call("get_settings_path"), FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_settings_round_trip_through_the_file() -> void:
	var saves: Node = _saves()
	saves.call("set_locale", "vi")
	saves.call("set_volume", &"SFX", 0.3)
	saves.call("set_fullscreen", true)
	check_eq(saves.call("rebind_action", &"dodge", _key_event(KEY_L)), &"", "dodge rebinds to L")
	check(FileAccess.file_exists(saves.call("get_settings_path")), "settings.cfg written")
	saves.call("reset_settings")
	check(TranslationServer.get_locale().begins_with("en"), "precondition: defaults in memory")
	check(not _bound_to(&"dodge", KEY_L), "precondition: default dodge key")
	saves.call("load_settings")
	check(TranslationServer.get_locale().begins_with("vi"), "language restored")
	check_eq(_settings().volumes[&"SFX"], 0.3, "SFX volume restored")
	check(_settings().fullscreen, "fullscreen restored")
	check(_bound_to(&"dodge", KEY_L), "dodge key restored in the InputMap")
	check(not _bound_to(&"dodge", KEY_SPACE), "old dodge key removed")


func test_unreadable_settings_file_gives_defaults() -> void:
	allowed_errors.append("ConfigFile parse error")
	_write_settings_text("[general\nlocale=\"vi")
	_saves().call("load_settings")
	check(TranslationServer.get_locale().begins_with("en"), "default language")
	check_eq(_settings().volumes[&"Master"], 1.0, "default volume")
	check(_bound_to(&"dodge", KEY_SPACE), "default keys")
	var config: ConfigFile = ConfigFile.new()
	check_eq(config.load(_saves().call("get_settings_path")), OK, "a valid file is written back")


func test_wrong_values_in_settings_are_ignored() -> void:
	_write_settings_text("""[general]
locale="fr"
[audio]
master="loud"
sfx=7.5
[display]
fullscreen=1
[keys]
dodge=[{"type": "key", "physical_keycode": -4}]
attack="nope"
teleport=[{"type": "key", "physical_keycode": 76}]
""")
	_saves().call("load_settings")
	check(TranslationServer.get_locale().begins_with("en"), "unknown language ignored")
	check_eq(_settings().volumes[&"Master"], 1.0, "non-number volume ignored")
	check_eq(_settings().volumes[&"SFX"], 1.0, "volume clamped to 1")
	check(not _settings().fullscreen, "non-bool fullscreen ignored")
	check(_bound_to(&"dodge", KEY_SPACE), "bad key code ignored")
	check(InputMap.action_get_events(&"attack").size() == 1, "bad binding list ignored")
	check(not InputMap.has_action(&"teleport"), "unknown actions are not created")


func test_old_save_language_moves_to_settings_once() -> void:
	write_save_text(OLD_SAVE)
	await boot_to_menu()
	check(TranslationServer.get_locale().begins_with("vi"), "language taken from the old save")
	var config: ConfigFile = ConfigFile.new()
	check_eq(config.load(_saves().call("get_settings_path")), OK, "settings.cfg created")
	check_eq(config.get_value("general", "locale"), "vi", "language stored in settings.cfg")
	check_eq(FileAccess.get_file_as_string(_saves().call("get_save_path")), OLD_SAVE, "old save left untouched")
	check(_saves().call("check_save"), "old save still offered for Continue")
	main.find_child("ContinueButton", true, false).emit_signal("pressed")
	await wait(0.4)
	check_eq(tree.root.get_node("GameState").get("day"), 3, "old save still loads")
	check_eq(_display().call("get_day_text"), "Ngày 3", "HUD shows the old save in Vietnamese")


func test_settings_file_wins_over_old_save_language() -> void:
	write_save_text(OLD_SAVE)
	_write_settings_text("[general]\nlocale=\"en\"\n")
	await boot_to_menu()
	check(TranslationServer.get_locale().begins_with("en"), "settings.cfg language is used")


func test_new_game_keeps_settings() -> void:
	_saves().call("set_locale", "vi")
	_saves().call("set_volume", &"Music", 0.5)
	_saves().call("rebind_action", &"interact", _key_event(KEY_F))
	var before: String = FileAccess.get_file_as_string(_saves().call("get_settings_path"))
	await start_main()
	check(TranslationServer.get_locale().begins_with("vi"), "language kept")
	check_eq(_settings().volumes[&"Music"], 0.5, "volume kept")
	check(_bound_to(&"interact", KEY_F), "key binding kept")
	check_eq(FileAccess.get_file_as_string(_saves().call("get_settings_path")), before, "settings.cfg unchanged")
	check_eq(_display().call("get_day_text"), "Ngày 1", "HUD in the kept language")


func test_changing_language_updates_the_hud() -> void:
	await start_main()
	check_eq(_display().call("get_day_text"), "Day 1", "precondition: English HUD")
	_saves().call("set_locale", "vi")
	await tree.process_frame
	check_eq(_display().call("get_day_text"), "Ngày 1", "HUD switches to Vietnamese")


func test_rebinding_refuses_keys_already_in_use() -> void:
	var saves: Node = _saves()
	check_eq(saves.call("rebind_action", &"attack", _key_event(KEY_W)), &"movement_up", "W belongs to movement_up")
	check_eq(saves.call("rebind_action", &"attack", _key_event(KEY_ESCAPE)), &"pause", "Esc belongs to pause")
	check_eq(InputMap.action_get_events(&"attack").size(), 1, "attack unchanged")
	check(InputMap.action_get_events(&"attack")[0] is InputEventMouseButton, "attack still on the mouse")
	check_eq(saves.call("rebind_action", &"dodge", _key_event(KEY_SPACE)), &"", "rebinding to its own key is fine")
	saves.call("rebind_action", &"dodge", _key_event(KEY_SHIFT))
	saves.call("reset_key_bindings")
	check(_bound_to(&"dodge", KEY_SPACE), "reset restores the default key")
	check(_bound_to(&"inventory", KEY_TAB) and _bound_to(&"inventory", KEY_I), "inventory keeps both default keys")
