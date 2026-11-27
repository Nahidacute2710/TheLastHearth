extends RefCounted
## Base for headless tests. Provides checks, waits and helpers to boot Main.

const MAIN_SCENE: String = "res://scenes/main/main.tscn"
const _ACTIONS: Array[StringName] = [
	&"movement_up", &"movement_down", &"movement_left", &"movement_right",
	&"interact", &"attack", &"dodge", &"inventory", &"pause",
]

var tree: SceneTree = null
var failures: Array[String] = []
var main: Node = null


func before_each() -> void:
	pass


func after_each() -> void:
	for action: StringName in _ACTIONS:
		Input.action_release(action)
	if main != null:
		main.queue_free()
		main = null
	TranslationServer.set_locale("en")
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


## Boots Main (which loads the tavern) and waits for the fade-in to finish.
func start_main() -> Node:
	main = (load(MAIN_SCENE) as PackedScene).instantiate()
	tree.root.add_child(main)
	await wait(0.4)
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
