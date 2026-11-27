extends Node
## Switches levels inside Main/LevelRoot with a fade to black. Main stays alive for the whole game,
## so UI and the fade overlay survive level changes.

const TAVERN: StringName = &"tavern"
const DUNGEON: StringName = &"dungeon"
const FADE_DURATION: float = 0.25

const _LEVEL_PATHS: Dictionary[StringName, String] = {
	TAVERN: "res://scenes/tavern/tavern_main_hall.tscn",
	DUNGEON: "res://scenes/dungeon/abandoned_mine.tscn",
}
const _FADE_COLOR: Color = Color(0.0862745, 0.0784314, 0.109804, 1.0)

var current_level_id: StringName = &""

var _level_root: Node = null
var _current_level: Level = null
var _fade_rect: ColorRect = null
var _is_transitioning: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = _FADE_COLOR
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.modulate.a = 0.0
	layer.add_child(_fade_rect)


## Called once by Main. Loads the first level and fades in from black.
func start(level_root: Node, level_id: StringName, spawn_id: StringName = &"") -> void:
	_level_root = level_root
	_current_level = null
	_is_transitioning = false
	_fade_rect.modulate.a = 1.0
	_swap_level(level_id, spawn_id)
	await _fade_to(0.0)


func go_to(level_id: StringName, spawn_id: StringName = &"") -> void:
	if _is_transitioning:
		return
	if _level_root == null:
		push_error("SceneRouter.go_to called before start().")
		return
	if not _LEVEL_PATHS.has(level_id):
		push_error("SceneRouter: unknown level '%s'." % level_id)
		return
	_is_transitioning = true
	_level_root.process_mode = Node.PROCESS_MODE_DISABLED
	await _fade_to(1.0)
	_swap_level(level_id, spawn_id)
	_level_root.process_mode = Node.PROCESS_MODE_INHERIT
	await _fade_to(0.0)
	_is_transitioning = false


func is_transitioning() -> bool:
	return _is_transitioning


func get_current_level() -> Level:
	return _current_level if is_instance_valid(_current_level) else null


func _swap_level(level_id: StringName, spawn_id: StringName) -> void:
	var scene: PackedScene = load(_LEVEL_PATHS[level_id]) as PackedScene
	var level: Level = scene.instantiate() as Level if scene != null else null
	if level == null:
		push_error("SceneRouter: level '%s' is missing or does not extend Level." % level_id)
		return
	if _current_level != null:
		_level_root.remove_child(_current_level)
		_current_level.queue_free()
	_level_root.add_child(level)
	level.place_player(spawn_id)
	_current_level = level
	current_level_id = level_id
	EventBus.level_changed.emit(level_id)


func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "modulate:a", alpha, FADE_DURATION)
	await tween.finished
