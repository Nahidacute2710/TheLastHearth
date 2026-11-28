extends RefCounted
## Base for headless tests. Provides checks, waits and helpers to boot Main.

const MAIN_SCENE: String = "res://scenes/main/main.tscn"
const _ACTIONS: Array[StringName] = [
	&"movement_up", &"movement_down", &"movement_left", &"movement_right",
	&"interact", &"attack", &"dodge", &"inventory", &"pause",
]

var tree: SceneTree = null
var failures: Array[String] = []
## Engine errors a test provokes on purpose (substring match). Anything else logged fails the test.
var allowed_errors: PackedStringArray = []
var main: Node = null


const TEST_SAVE_DIR: String = "user://test_saves/"


func before_each() -> void:
	tree.root.get_node("GameState").call("start_new_game")
	var saves: Node = tree.root.get_node("SaveManager")
	saves.set("save_dir", TEST_SAVE_DIR)
	saves.set("settings_dir", TEST_SAVE_DIR)
	saves.call("delete_save")
	_remove_test_file(saves.call("get_settings_path"))
	_remove_test_file(saves.call("get_backup_path"))


func after_each() -> void:
	for action: StringName in _ACTIONS:
		Input.action_release(action)
	tree.paused = false
	if main != null:
		main.queue_free()
		main = null
	var saves: Node = tree.root.get_node("SaveManager")
	saves.call("reset_settings")
	TranslationServer.set_locale("en")
	saves.call("delete_save")
	_remove_test_file(saves.call("get_settings_path"))
	_remove_test_file(saves.call("get_backup_path"))
	await tree.process_frame
	await tree.process_frame


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func check_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])


func wait(seconds: float) -> void:
	await tree.create_timer(seconds).timeout


func wait_physics(frames: int) -> void:
	for i: int in frames:
		await tree.physics_frame


## Boots Main, starts a new game (tavern) and waits for the fade-in to finish.
func start_main() -> Node:
	main = (load(MAIN_SCENE) as PackedScene).instantiate()
	tree.root.add_child(main)
	main.call("start_new_game")
	await wait(0.4)
	return main


## Boots Main and stays on the main menu.
func boot_to_menu() -> Node:
	main = (load(MAIN_SCENE) as PackedScene).instantiate()
	tree.root.add_child(main)
	await tree.process_frame
	return main


func router() -> Node:
	return tree.root.get_node("SceneRouter")


func level() -> Node2D:
	return router().call("get_current_level") as Node2D


func player() -> CharacterBody2D:
	var current: Node2D = level()
	return current.find_child("Player", true, false) as CharacterBody2D if current != null else null


func node_count() -> int:
	return tree.get_node_count()


## Sends a press + release of an input action through the normal input pipeline.
func tap(action: StringName) -> void:
	var down: InputEventAction = InputEventAction.new()
	down.action = action
	down.pressed = true
	Input.parse_input_event(down)
	await tree.process_frame
	var up: InputEventAction = InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)
	await tree.process_frame


func hold(action: StringName, seconds: float) -> void:
	Input.action_press(action)
	await wait(seconds)
	Input.action_release(action)


func _remove_test_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func write_save_text(text: String) -> void:
	DirAccess.make_dir_recursive_absolute(TEST_SAVE_DIR)
	var file: FileAccess = FileAccess.open(tree.root.get_node("SaveManager").call("get_save_path"), FileAccess.WRITE)
	file.store_string(text)
	file.close()
