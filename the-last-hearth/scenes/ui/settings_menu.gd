class_name SettingsMenu
extends Control
## Settings: language, bus volumes, fullscreen and key bindings. Opened from the main menu or the pause
## menu (which it hides and shows again on close). Every change is applied at once and written to
## settings.cfg through SaveManager. Esc (pause) closes it, or cancels a key capture first.
## Runs while the tree is paused. Rows are built in code from GameSettings.

signal closed

const SLIDER_STEP: float = 0.05
const KEY_BUTTON_WIDTH: float = 96.0
## Over the main menu the world must not show through; over the pause menu it is dimmed.
const DIM_OVER_MENU: float = 1.0
const DIM_OVER_GAME: float = 0.85
const VOLUME_ROWS: Dictionary[StringName, StringName] = {
	&"Master": &"SETTINGS_VOLUME_MASTER",
	&"Music": &"SETTINGS_VOLUME_MUSIC",
	&"SFX": &"SETTINGS_VOLUME_SFX",
}

@onready var _dim: ColorRect = $Dim
@onready var _language_button: Button = %LanguageButton
@onready var _volume_grid: GridContainer = %VolumeGrid
@onready var _fullscreen_check: CheckButton = %FullscreenCheck
@onready var _key_grid: GridContainer = %KeyGrid
@onready var _reset_keys_button: Button = %ResetKeysButton
@onready var _back_button: Button = %BackButton
@onready var _error_label: Label = %KeyError

var _sliders: Dictionary[StringName, HSlider] = {}
var _volume_labels: Dictionary[StringName, Label] = {}
var _key_buttons: Dictionary[StringName, Button] = {}
var _capturing: StringName = &""
var _return_to: Control = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_build_volume_rows()
	_build_key_rows()
	_language_button.pressed.connect(_on_language_pressed)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_reset_keys_button.pressed.connect(_on_reset_keys_pressed)
	_back_button.pressed.connect(close)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if _capturing != &"":
		_capture(event)
		return
	if event.is_action_pressed(&"pause") and not event.is_echo():
		get_viewport().set_input_as_handled()
		close()


## Shows the menu over `from` (hidden until the menu closes).
func open(from: Control = null) -> void:
	_return_to = from
	_dim.color.a = DIM_OVER_GAME if from is PauseMenu else DIM_OVER_MENU
	if from != null:
		from.hide()
	_error_label.text = ""
	_capturing = &""
	_refresh()
	show()
	_back_button.grab_focus()


func close() -> void:
	_capturing = &""
	hide()
	if _return_to != null:
		_return_to.show()
		if _return_to.has_method(&"focus_settings_button"):
			_return_to.call(&"focus_settings_button")
	_return_to = null
	closed.emit()


func is_open() -> bool:
	return visible


func is_capturing() -> bool:
	return _capturing != &""


func press_language() -> void:
	_on_language_pressed()


func set_volume_slider(bus: StringName, value: float) -> void:
	_sliders[bus].value = value


func get_volume_text(bus: StringName) -> String:
	return _volume_labels[bus].text


func get_language_text() -> String:
	return _language_button.text


func set_fullscreen_check(enabled: bool) -> void:
	_fullscreen_check.button_pressed = enabled


func start_rebind(action: StringName) -> void:
	_key_buttons[action].pressed.emit()


func get_key_text(action: StringName) -> String:
	return _key_buttons[action].text


func get_error_text() -> String:
	return _error_label.text


func press_reset_keys() -> void:
	_reset_keys_button.pressed.emit()


func _build_volume_rows() -> void:
	for bus: StringName in VOLUME_ROWS:
		var label: Label = Label.new()
		label.text = VOLUME_ROWS[bus]
		_volume_grid.add_child(label)
		var slider: HSlider = HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = SLIDER_STEP
		slider.custom_minimum_size = Vector2(90.0, 0.0)
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.value_changed.connect(_on_volume_changed.bind(bus))
		_volume_grid.add_child(slider)
		_sliders[bus] = slider
		var percent: Label = Label.new()
		percent.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		percent.custom_minimum_size = Vector2(30.0, 0.0)
		percent.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_volume_grid.add_child(percent)
		_volume_labels[bus] = percent


func _build_key_rows() -> void:
	for action: StringName in GameSettings.REBINDABLE_ACTIONS:
		var label: Label = Label.new()
		label.text = "ACTION_" + String(action).to_upper()
		_key_grid.add_child(label)
		var button: Button = Button.new()
		button.name = String(action)
		button.theme_type_variation = &"CompactButton"
		button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		button.custom_minimum_size = Vector2(KEY_BUTTON_WIDTH, 0.0)
		button.pressed.connect(_on_key_button_pressed.bind(action))
		_key_grid.add_child(button)
		_key_buttons[action] = button


func _refresh() -> void:
	var settings: GameSettings = SaveManager.settings
	_language_button.text = tr(&"LANGUAGE_NAME")
	for bus: StringName in _sliders:
		_sliders[bus].set_value_no_signal(settings.volumes.get(bus, 1.0))
		_volume_labels[bus].text = "%d%%" % roundi(settings.volumes.get(bus, 1.0) * 100.0)
	_fullscreen_check.set_pressed_no_signal(settings.fullscreen)
	for action: StringName in _key_buttons:
		if action == _capturing:
			_key_buttons[action].text = tr(&"SETTINGS_PRESS_KEY")
			continue
		var names: PackedStringArray = []
		for event: InputEvent in settings.get_events(action):
			names.append(GameSettings.describe_event(event))
		_key_buttons[action].text = " / ".join(names)


func _capture(event: InputEvent) -> void:
	var pressed: bool = (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed() and not event.is_echo()
	if event is InputEventKey or event is InputEventMouseButton or event.is_action(&"pause"):
		get_viewport().set_input_as_handled()
	if not pressed:
		return
	var action: StringName = _capturing
	if event is InputEventKey and (event as InputEventKey).physical_keycode == KEY_ESCAPE:
		_capturing = &""
		_refresh()
		_key_buttons[action].grab_focus()
		return
	if not GameSettings.is_bindable(event):
		return
	var conflict: StringName = SaveManager.rebind_action(action, event)
	_capturing = &""
	if conflict != &"":
		_error_label.text = tr(&"SETTINGS_KEY_IN_USE") % tr("ACTION_" + String(conflict).to_upper())
	else:
		_error_label.text = ""
	_refresh()
	_key_buttons[action].grab_focus()


func _on_key_button_pressed(action: StringName) -> void:
	_capturing = action
	_error_label.text = ""
	_refresh()


func _on_language_pressed() -> void:
	SaveManager.set_locale("vi" if SaveManager.settings.locale == "en" else "en")


func _on_volume_changed(value: float, bus: StringName) -> void:
	SaveManager.set_volume(bus, value)
	_volume_labels[bus].text = "%d%%" % roundi(value * 100.0)


func _on_fullscreen_toggled(enabled: bool) -> void:
	SaveManager.set_fullscreen(enabled)


func _on_reset_keys_pressed() -> void:
	SaveManager.reset_key_bindings()
	_error_label.text = ""
	_refresh()
