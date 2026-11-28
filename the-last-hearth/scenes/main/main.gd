extends Node
## Boot scene root. Lives for the whole game; SceneRouter swaps levels inside LevelRoot.
## Starts on the main menu. New Game / Continue load the tavern; the pause menu can return here.
## Closing the window (X) saves when in the tavern, never in the mine.

@onready var _level_root: Node2D = %LevelRoot
@onready var _main_menu: MainMenu = %MainMenu
@onready var _pause_menu: PauseMenu = %PauseMenu

## Tests turn this off so a simulated close request does not end the test run.
var quit_on_close: bool = true


func _ready() -> void:
	_main_menu.continue_requested.connect(continue_game)
	_main_menu.new_game_requested.connect(start_new_game)
	_main_menu.quit_requested.connect(_on_quit_requested)
	_pause_menu.main_menu_requested.connect(return_to_menu)
	get_tree().set_auto_accept_quit(false)
	SaveManager.apply_saved_locale()
	_main_menu.open()


## Fresh session in the tavern. Overwrites the save right away (the menu asked first).
func start_new_game() -> void:
	GameState.start_new_game()
	_main_menu.close()
	SceneRouter.start(_level_root, SceneRouter.TAVERN)
	SaveManager.save_game()


## Loads the save and enters the tavern at its spawn point. Back to the menu (with the error) on failure.
func continue_game() -> void:
	if SaveManager.load_game() != SaveManager.LoadResult.OK:
		_main_menu.open()
		return
	_main_menu.close()
	SceneRouter.start(_level_root, SceneRouter.TAVERN)


## From the pause menu. Saves only in the tavern; leaving from the mine loses the run.
func return_to_menu() -> void:
	get_tree().paused = false
	_leave_level_and_save_if_in_tavern()
	_main_menu.open()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_leave_level_and_save_if_in_tavern()
		if quit_on_close:
			get_tree().quit()


func _exit_tree() -> void:
	get_tree().set_auto_accept_quit(true)


## Unload first: a pot still cooking finishes when the tavern leaves the tree, so the save includes it.
## Leaving from the mine saves nothing (the run is lost).
func _leave_level_and_save_if_in_tavern() -> void:
	var in_tavern: bool = SceneRouter.current_level_id == SceneRouter.TAVERN
	SceneRouter.unload()
	if in_tavern:
		SaveManager.save_game()


func _on_quit_requested() -> void:
	get_tree().quit()
