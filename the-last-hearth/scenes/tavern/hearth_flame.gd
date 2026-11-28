class_name HearthFlame
extends StaticBody2D
## The tavern fireplace: the Hearth Flame (Ngọn Lửa Gốc). Interacting opens the HearthPanel.
## The fire and its light grow with the Hearth level (placeholder: flame sprite size and brightness,
## a PointLight2D). Kindling plays a sound, flares the fire and shows a toast with the new unlock.

const FLARE_TIME: float = 0.6
const FLARE_SCALE: float = 1.6

## Per level (index 0 = level 1). Placeholder look, tuned by eye.
@export var flame_scales: PackedFloat32Array = [0.55, 0.7, 0.85, 1.0, 1.2]
@export var flame_brightness: PackedFloat32Array = [0.75, 0.9, 1.0, 1.15, 1.3]
@export var light_energies: PackedFloat32Array = [0.3, 0.42, 0.54, 0.66, 0.8]
@export var light_scales: PackedFloat32Array = [1.2, 1.6, 2.0, 2.4, 2.9]

var _time: float = 0.0
var _flare: float = 0.0

@onready var _flame: Sprite2D = %Flame
@onready var _light: PointLight2D = %Light
@onready var _interactable: Interactable = %Interactable


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	EventBus.hearth_level_changed.connect(_on_level_changed)
	EventBus.hearth_kindled.connect(_on_kindled)
	_apply_level(GameState.hearth_level)


func _process(delta: float) -> void:
	_time += delta
	_flare = maxf(_flare - delta / FLARE_TIME, 0.0)
	var index: int = _level_index(GameState.hearth_level)
	var flicker: float = 1.0 + 0.06 * sin(_time * 9.0) + 0.03 * sin(_time * 23.0)
	var flare: float = 1.0 + (FLARE_SCALE - 1.0) * _flare
	_flame.scale = Vector2.ONE * flame_scales[index] * flicker * flare
	_light.energy = light_energies[index] * (0.95 + 0.05 * sin(_time * 11.0)) * flare


## Current look values, for tests.
func get_flame_scale() -> float:
	return flame_scales[_level_index(GameState.hearth_level)]


func get_light_energy() -> float:
	return light_energies[_level_index(GameState.hearth_level)]


func _apply_level(level: int) -> void:
	var index: int = _level_index(level)
	var bright: float = flame_brightness[index]
	_flame.modulate = Color(bright, bright, bright)
	_light.texture_scale = light_scales[index]


func _level_index(level: int) -> int:
	return clampi(level - 1, 0, flame_scales.size() - 1)


func _on_interacted(_actor: Node2D) -> void:
	EventBus.hearth_panel_requested.emit()


func _on_level_changed(level: int) -> void:
	_apply_level(level)


func _on_kindled(level: int) -> void:
	_flare = 1.0
	EventBus.sfx_requested.emit(&"hearth_kindle")
	var data: HearthLevelData = GameState.get_hearth_table().get_level(level)
	if data != null:
		EventBus.toast_requested.emit(tr(&"TOAST_HEARTH_KINDLED") % [level, tr(data.unlock_key)])
