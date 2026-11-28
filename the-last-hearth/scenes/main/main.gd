extends Node
## Boot scene root. Lives for the whole game; SceneRouter swaps levels inside LevelRoot.
## Starts on the main menu. New Game / Continue load the tavern; the pause menu can return here.

@onready var _level_root: Node2D = %LevelRoot
@onready var _main_menu: MainMenu = %MainMenu
@onready var _pause_menu: PauseMenu = %PauseMenu


func _ready() -> void:
	_main_menu.continue_requested.connect(continue_game)
	_main_menu.new_game_requested.connect(start_new_game)
	_main_menu.quit_requested.connect(_on_quit_requested)
	_pause_menu.main_menu_requested.connect(return_to_menu)
	SaveManager.apply_saved_locale()
	_main_menu.open()


## Fresh session in the tavern. Overwrites the save right away (the menu asked first).
func start_new_game() -> void:
	GameState.reset_session()
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
	if SceneRouter.current_level_id == SceneRouter.TAVERN:
		SaveManager.save_game()
	SceneRouter.unload()
	_main_menu.open()


func _on_quit_requested() -> void:
	get_tree().quit()
