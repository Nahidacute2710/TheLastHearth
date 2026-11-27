extends Label
## Shows "[key] action" above the focused interactable. Text is built from translation keys.

const SCREEN_OFFSET: Vector2 = Vector2(0.0, -28.0)

var _target: Interactable = null


func _ready() -> void:
	hide()
	EventBus.interaction_focus_changed.connect(_on_focus_changed)


func _process(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var anchor: Vector2 = _target.get_global_transform_with_canvas().origin + SCREEN_OFFSET
	position = (anchor - size * 0.5).round()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _target != null:
		_refresh_text()


func _on_focus_changed(interactable: Interactable) -> void:
	_target = interactable
	if _target == null:
		hide()
		return
	_refresh_text()
	show()


func _refresh_text() -> void:
	text = tr(&"UI_PROMPT_FORMAT") % [_get_interact_key_label(), tr(_target.prompt_key)]
	reset_size()


static func _get_interact_key_label() -> String:
	for event: InputEvent in InputMap.action_get_events(&"interact"):
		if event is InputEventKey:
			return (event as InputEventKey).as_text_physical_keycode()
	return "?"
