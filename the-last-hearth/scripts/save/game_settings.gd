class_name GameSettings
extends RefCounted
## Player settings, kept apart from the game save (user://settings.cfg, read and written by SaveManager):
## language, bus volumes, fullscreen and key bindings. "New Game" never touches them.
## Key bindings are stored as plain dictionaries ({"type": "key", "physical_keycode": n} or
## {"type": "mouse", "button_index": n}); nothing else in the file is turned into an object.

const SETTINGS_VERSION: int = 1
const LOCALES: Array[String] = ["en", "vi"]
const BUSES: Array[StringName] = [&"Master", &"Music", &"SFX"]
## Actions the player can rebind. `pause` (Esc) stays fixed so menus can always be closed.
const REBINDABLE_ACTIONS: Array[StringName] = [
	&"movement_up", &"movement_down", &"movement_left", &"movement_right",
	&"interact", &"attack", &"dodge", &"inventory",
]
const FIXED_ACTIONS: Array[StringName] = [&"pause"]

var locale: String = "en"
var volumes: Dictionary[StringName, float] = {}
var fullscreen: bool = false
## Only actions that differ from the defaults are stored here.
var bindings: Dictionary[StringName, Array] = {}

var _default_events: Dictionary[StringName, Array] = {}


func _init() -> void:
	for action: StringName in REBINDABLE_ACTIONS + FIXED_ACTIONS:
		if InputMap.has_action(action):
			_default_events[action] = InputMap.action_get_events(action).duplicate()
	reset_to_defaults()


func reset_to_defaults() -> void:
	locale = _default_locale()
	for bus: StringName in BUSES:
		volumes[bus] = 1.0
	fullscreen = false
	bindings.clear()


## Applies everything to the engine: locale, bus volumes, window mode and the InputMap.
func apply() -> void:
	apply_locale()
	for bus: StringName in BUSES:
		apply_volume(bus)
	apply_fullscreen()
	apply_bindings()


func apply_locale() -> void:
	TranslationServer.set_locale(locale)


func apply_volume(bus: StringName) -> void:
	var index: int = AudioServer.get_bus_index(bus)
	if index < 0:
		return
	var linear: float = volumes.get(bus, 1.0)
	AudioServer.set_bus_mute(index, linear <= 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))


func apply_fullscreen() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var window: Window = Engine.get_main_loop().root as Window
	if window == null:
		return
	var wanted: Window.Mode = Window.MODE_FULLSCREEN if fullscreen else Window.MODE_WINDOWED
	if window.mode != wanted:
		window.mode = wanted


func apply_bindings() -> void:
	for action: StringName in REBINDABLE_ACTIONS:
		if not InputMap.has_action(action):
			continue
		InputMap.action_erase_events(action)
		for event: InputEvent in get_events(action):
			InputMap.action_add_event(action, event)


## Events currently bound to an action (custom binding or the default).
func get_events(action: StringName) -> Array[InputEvent]:
	var events: Array[InputEvent] = []
	var source: Array = bindings[action] if bindings.has(action) else _default_events.get(action, [])
	for event: Variant in source:
		if event is InputEvent:
			events.append(event as InputEvent)
	return events


## The rebindable or fixed action that already uses this key/button, or &"".
func find_action_using(event: InputEvent) -> StringName:
	for action: StringName in REBINDABLE_ACTIONS + FIXED_ACTIONS:
		for bound: InputEvent in get_events(action):
			if same_input(bound, event):
				return action
	return &""


## Binds one key or mouse button to an action. Returns the action that already uses it (and changes
## nothing), or &"" on success.
func rebind(action: StringName, event: InputEvent) -> StringName:
	if not REBINDABLE_ACTIONS.has(action) or not is_bindable(event):
		return &"invalid"
	var owner: StringName = find_action_using(event)
	if owner != &"" and owner != action:
		return owner
	bindings[action] = [event]
	apply_bindings()
	return &""


func reset_bindings() -> void:
	bindings.clear()
	apply_bindings()


func to_config() -> ConfigFile:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("meta", "settings_version", SETTINGS_VERSION)
	config.set_value("general", "locale", locale)
	for bus: StringName in BUSES:
		config.set_value("audio", String(bus).to_lower(), volumes.get(bus, 1.0))
	config.set_value("display", "fullscreen", fullscreen)
	for action: StringName in bindings:
		var list: Array = []
		for event: InputEvent in get_events(action):
			list.append(event_to_dict(event))
		config.set_value("keys", String(action), list)
	return config


## Reads values from a config; anything missing or of the wrong type keeps its default.
func from_config(config: ConfigFile) -> void:
	reset_to_defaults()
	var saved_locale: Variant = config.get_value("general", "locale", locale)
	if saved_locale is String and LOCALES.has(saved_locale):
		locale = saved_locale
	for bus: StringName in BUSES:
		var value: Variant = config.get_value("audio", String(bus).to_lower(), 1.0)
		if value is float or value is int:
			volumes[bus] = clampf(float(value), 0.0, 1.0)
	var saved_fullscreen: Variant = config.get_value("display", "fullscreen", false)
	if saved_fullscreen is bool:
		fullscreen = saved_fullscreen
	if config.has_section("keys"):
		for key: String in config.get_section_keys("keys"):
			var action: StringName = StringName(key)
			var list: Variant = config.get_value("keys", key)
			if not REBINDABLE_ACTIONS.has(action) or not list is Array:
				continue
			var events: Array = []
			for entry: Variant in list:
				var event: InputEvent = dict_to_event(entry)
				if event != null:
					events.append(event)
			if not events.is_empty():
				bindings[action] = events


## Keys and mouse buttons can be bound; the mouse wheel cannot.
static func is_bindable(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		var index: MouseButton = (event as InputEventMouseButton).button_index
		return index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_XBUTTON1, MOUSE_BUTTON_XBUTTON2]
	return event is InputEventKey and not event_to_dict(event).is_empty()


## Short name of a key or mouse button for the settings menu (translated for the mouse).
static func describe_event(event: InputEvent) -> String:
	if event is InputEventKey:
		var key: InputEventKey = event as InputEventKey
		return key.as_text_physical_keycode() if key.physical_keycode != KEY_NONE else key.as_text_keycode()
	if event is InputEventMouseButton:
		match (event as InputEventMouseButton).button_index:
			MOUSE_BUTTON_LEFT:
				return TranslationServer.translate(&"KEY_MOUSE_LEFT")
			MOUSE_BUTTON_RIGHT:
				return TranslationServer.translate(&"KEY_MOUSE_RIGHT")
			MOUSE_BUTTON_MIDDLE:
				return TranslationServer.translate(&"KEY_MOUSE_MIDDLE")
			var other:
				return TranslationServer.translate(&"KEY_MOUSE_OTHER") % int(other)
	return "?"


static func normalize_locale(value: String) -> String:
	for code: String in LOCALES:
		if value.begins_with(code):
			return code
	return ""


static func same_input(a: InputEvent, b: InputEvent) -> bool:
	var da: Dictionary = event_to_dict(a)
	return not da.is_empty() and da == event_to_dict(b)


static func event_to_dict(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var key: InputEventKey = event as InputEventKey
		var code: int = key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode
		return {"type": "key", "physical_keycode": code}
	if event is InputEventMouseButton:
		return {"type": "mouse", "button_index": (event as InputEventMouseButton).button_index}
	return {}


static func dict_to_event(value: Variant) -> InputEvent:
	if not value is Dictionary:
		return null
	var data: Dictionary = value as Dictionary
	var type: Variant = data.get("type")
	if type == "key" and (data.get("physical_keycode") is int or data.get("physical_keycode") is float):
		var code: int = int(data["physical_keycode"])
		if code <= 0:
			return null
		var key: InputEventKey = InputEventKey.new()
		key.physical_keycode = code as Key
		return key
	if type == "mouse" and (data.get("button_index") is int or data.get("button_index") is float):
		var index: int = int(data["button_index"])
		if index < MOUSE_BUTTON_LEFT or index > MOUSE_BUTTON_XBUTTON2:
			return null
		var button: InputEventMouseButton = InputEventMouseButton.new()
		button.button_index = index as MouseButton
		return button
	return null


static func _default_locale() -> String:
	var from_os: String = normalize_locale(OS.get_locale_language())
	return from_os if from_os != "" else "en"
