class_name MainMenu
extends Control
## Main menu: Continue (only with a valid save), New Game (asks before overwriting), Settings, Quit.
## Shows one line when the save could not be read. All text is translation keys.

signal continue_requested
signal new_game_requested
signal quit_requested
signal settings_requested

@onready var _continue_button: Button = %ContinueButton
@onready var _new_game_button: Button = %NewGameButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _error_label: Label = %ErrorLabel
@onready var _buttons: Control = %Buttons
@onready var _confirm: Control = %Confirm
@onready var _confirm_yes: Button = %ConfirmYes
@onready var _confirm_no: Button = %ConfirmNo


func _ready() -> void:
	_continue_button.pressed.connect(_on_continue_pressed)
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_settings_button.pressed.connect(func() -> void: settings_requested.emit())
	_quit_button.pressed.connect(func() -> void: quit_requested.emit())
	_confirm_yes.pressed.connect(_on_confirm_yes)
	_confirm_no.pressed.connect(_close_confirm)


## Re-checks the save (a bad file is moved to .bak here) and shows the menu.
func open() -> void:
	var has_valid_save: bool = SaveManager.check_save()
	_continue_button.visible = has_valid_save
	_error_label.text = String(SaveManager.last_error_key)
	_error_label.visible = SaveManager.last_error_key != &""
	_close_confirm()
	show()
	(_continue_button if has_valid_save else _new_game_button).grab_focus()


func close() -> void:
	hide()


func is_open() -> bool:
	return visible


## Called by the settings menu when it closes.
func focus_settings_button() -> void:
	_settings_button.grab_focus()


func is_confirm_open() -> bool:
	return _confirm.visible


func _on_continue_pressed() -> void:
	continue_requested.emit()


func _on_new_game_pressed() -> void:
	if SaveManager.has_save_file():
		_buttons.hide()
		_confirm.show()
		_confirm_no.grab_focus()
	else:
		new_game_requested.emit()


func _on_confirm_yes() -> void:
	_close_confirm()
	new_game_requested.emit()


func _close_confirm() -> void:
	_confirm.hide()
	_buttons.show()
