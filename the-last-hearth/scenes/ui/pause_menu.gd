class_name PauseMenu
extends Control
## Esc pause menu: Resume / Settings / Back to main menu. Uses get_tree().paused; this node runs while paused.
## While the settings menu is open this node is hidden but the game stays paused.
## Reads Esc in _unhandled_input, so an open inventory (which handles Esc in _input) closes first.

signal main_menu_requested
signal settings_requested

@onready var _resume_button: Button = %ResumeButton
@onready var _settings_button: Button = %SettingsButton
@onready var _main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	hide()
	_resume_button.pressed.connect(close)
	_settings_button.pressed.connect(func() -> void: settings_requested.emit())
	_main_menu_button.pressed.connect(_on_main_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"pause") or event.is_echo():
		return
	if visible:
		get_viewport().set_input_as_handled()
		close()
	elif SceneRouter.get_current_level() != null and not SceneRouter.is_transitioning() and not get_tree().paused:
		get_viewport().set_input_as_handled()
		open()


func open() -> void:
	show()
	get_tree().paused = true
	_resume_button.grab_focus()


func close() -> void:
	hide()
	get_tree().paused = false


func is_open() -> bool:
	return visible


## Called by the settings menu when it closes.
func focus_settings_button() -> void:
	_settings_button.grab_focus()


func _on_main_menu_pressed() -> void:
	hide()
	main_menu_requested.emit()
