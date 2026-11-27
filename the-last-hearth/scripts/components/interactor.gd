class_name Interactor
extends Node2D
## Player-side component. Tracks interactables that report the player in range,
## focuses the nearest one and triggers it on the "interact" action.

var _candidates: Array[Interactable] = []
var _focused: Interactable = null


func _ready() -> void:
	EventBus.interactable_available.connect(_on_interactable_available)
	EventBus.interactable_unavailable.connect(_on_interactable_unavailable)


func _exit_tree() -> void:
	if _focused != null:
		_focused = null
		EventBus.interaction_focus_changed.emit(null)


func _physics_process(_delta: float) -> void:
	_update_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact") and _focused != null:
		get_viewport().set_input_as_handled()
		_focused.interact(owner as Node2D)


func get_focused() -> Interactable:
	return _focused


func _update_focus() -> void:
	var nearest: Interactable = null
	var nearest_distance: float = INF
	for candidate: Interactable in _candidates:
		if not candidate.enabled:
			continue
		var distance: float = global_position.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	if nearest != _focused:
		_focused = nearest
		EventBus.interaction_focus_changed.emit(_focused)


func _on_interactable_available(interactable: Interactable) -> void:
	if not _candidates.has(interactable):
		_candidates.append(interactable)


func _on_interactable_unavailable(interactable: Interactable) -> void:
	_candidates.erase(interactable)
	if interactable == _focused:
		_update_focus()
