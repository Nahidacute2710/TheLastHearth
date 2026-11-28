extends "res://tests/test_case.gd"
## VSA3: settings menu from the main menu and the pause menu.


func _saves() -> Node:
	return tree.root.get_node("SaveManager")


func _settings_menu() -> Node:
	return main.find_child("SettingsMenu", true, false)


func _menu() -> Node:
	return main.find_child("MainMenu", true, false)


func _pause() -> Node:
	return main.find_child("PauseMenu", true, false)


func _display() -> Node:
	return main.find_child("DayGoldDisplay", true, false)


func _press_key(keycode: Key) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = keycode
		event.physical_keycode = keycode
		event.pressed = pressed
		Input.parse_input_event(event)
		await tree.process_frame


func _bound_to(action: StringName, keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == keycode:
			return true
	return false


func _saved_config() -> ConfigFile:
	var config: ConfigFile = ConfigFile.new()
	config.load(_saves().call("get_settings_path"))
	return config


func test_main_menu_opens_and_returns_from_settings() -> void:
	await boot_to_menu()
	var button: Button = _menu().find_child("SettingsButton", true, false) as Button
	check(button.visible, "Settings button on the main menu")
	button.pressed.emit()
	check(_settings_menu().call("is_open"), "settings open")
	check(not _menu().visible, "main menu hidden behind settings")
	_settings_menu().find_child("BackButton", true, false).emit_signal("pressed")
	check(not _settings_menu().call("is_open"), "Back closes settings")
	check(_menu().visible, "main menu shown again")
	check(button.has_focus(), "focus returns to the Settings button")


func test_esc_closes_settings_before_the_pause_menu() -> void:
	await start_main()
	await tap(&"pause")
	check(_pause().call("is_open"), "pause open")
	_pause().find_child("SettingsButton", true, false).emit_signal("pressed")
	check(_settings_menu().call("is_open"), "settings open from pause")
	await tap(&"pause")
	check(not _settings_menu().call("is_open"), "Esc closes settings")
	check(_pause().call("is_open"), "pause menu still open")
	check(tree.paused, "game still paused")
	await tap(&"pause")
	check(not _pause().call("is_open"), "next Esc closes pause")
	check(not tree.paused, "game resumes")


func test_language_button_switches_text_everywhere() -> void:
	await start_main()
	_settings_menu().call("open", null)
	check_eq(_settings_menu().call("get_language_text"), "English", "shows the current language")
	_settings_menu().call("press_language")
	await tree.process_frame
	check(TranslationServer.get_locale().begins_with("vi"), "language switched")
	check_eq(_settings_menu().call("get_language_text"), "Tiếng Việt", "button shows the new language")
	check_eq(_display().call("get_day_text"), "Ngày 1", "HUD switched too")
	check_eq(str(_saved_config().get_value("general", "locale")), "vi", "saved to settings.cfg")
	check_eq(_settings_menu().call("get_key_text", &"attack"), "Chuột trái", "mouse names are translated")


func test_volume_slider_changes_bus_and_file() -> void:
	await boot_to_menu()
	_settings_menu().call("open", _menu())
	_settings_menu().call("set_volume_slider", &"Master", 0.25)
	check_eq(_settings_menu().call("get_volume_text", &"Master"), "25%", "percent shown")
	check(absf(AudioServer.get_bus_volume_db(0) - linear_to_db(0.25)) < 0.01, "Master bus volume applied")
	check_eq(_saved_config().get_value("audio", "master"), 0.25, "saved to settings.cfg")
	_settings_menu().call("set_volume_slider", &"Master", 0.0)
	check(AudioServer.is_bus_mute(0), "0% mutes the bus")
	check_eq(_settings_menu().call("get_volume_text", &"Master"), "0%", "0% shown")


func test_fullscreen_option_is_saved() -> void:
	await boot_to_menu()
	_settings_menu().call("open", _menu())
	_settings_menu().call("set_fullscreen_check", true)
	check(_saves().get("settings").get("fullscreen"), "fullscreen on")
	check_eq(_saved_config().get_value("display", "fullscreen"), true, "saved to settings.cfg")
	_settings_menu().call("set_fullscreen_check", false)
	check_eq(_saved_config().get_value("display", "fullscreen"), false, "turned off again")


func test_rebinding_a_key_in_the_menu() -> void:
	await boot_to_menu()
	var menu: Node = _settings_menu()
	menu.call("open", _menu())
	check_eq(menu.call("get_key_text", &"dodge"), "Space", "dodge shows Space")
	check_eq(menu.call("get_key_text", &"inventory"), "Tab / I", "inventory shows both keys")
	menu.call("start_rebind", &"dodge")
	check(menu.call("is_capturing"), "waiting for a key")
	check_eq(menu.call("get_key_text", &"dodge"), "Press a key...", "button asks for a key")
	await _press_key(KEY_L)
	check(not menu.call("is_capturing"), "capture finished")
	check_eq(menu.call("get_key_text", &"dodge"), "L", "button shows the new key")
	check(_bound_to(&"dodge", KEY_L), "InputMap uses the new key")
	check(menu.call("is_open"), "menu still open")


func test_rebinding_to_a_used_key_is_refused() -> void:
	await boot_to_menu()
	var menu: Node = _settings_menu()
	menu.call("open", _menu())
	menu.call("start_rebind", &"dodge")
	await _press_key(KEY_W)
	check_eq(menu.call("get_error_text"), "Already used by: Move up", "conflict explained")
	check(_bound_to(&"dodge", KEY_SPACE), "dodge unchanged")
	check_eq(menu.call("get_key_text", &"dodge"), "Space", "button unchanged")


func test_esc_cancels_capture_without_closing() -> void:
	await boot_to_menu()
	var menu: Node = _settings_menu()
	menu.call("open", _menu())
	menu.call("start_rebind", &"interact")
	await _press_key(KEY_ESCAPE)
	check(not menu.call("is_capturing"), "capture cancelled")
	check(menu.call("is_open"), "menu stays open")
	check(_bound_to(&"interact", KEY_E), "interact unchanged")
	check_eq(menu.call("get_key_text", &"interact"), "E", "button shows the old key")


func test_reset_controls_button() -> void:
	await boot_to_menu()
	var menu: Node = _settings_menu()
	menu.call("open", _menu())
	menu.call("start_rebind", &"dodge")
	await _press_key(KEY_L)
	menu.call("press_reset_keys")
	check(_bound_to(&"dodge", KEY_SPACE), "dodge back to Space")
	check_eq(menu.call("get_key_text", &"dodge"), "Space", "button back to Space")
	check(not _saved_config().has_section("keys"), "no custom keys saved")
