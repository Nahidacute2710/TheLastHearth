extends Control
## Minimal HUD: player health pips in the top-left corner. No text, so nothing to translate.

const PIP_SIZE: Vector2 = Vector2(7.0, 7.0)
const PIP_GAP: float = 2.0
const FULL_COLOR: Color = Color(0.85, 0.27, 0.2)
const EMPTY_COLOR: Color = Color(0.2, 0.16, 0.16)
const OUTLINE_COLOR: Color = Color(0.0862745, 0.0784314, 0.109804)

var current_health: int = 0
var max_health: int = 0


func _ready() -> void:
	EventBus.player_health_changed.connect(_on_player_health_changed)


func _draw() -> void:
	for i: int in max_health:
		var rect: Rect2 = Rect2(Vector2(i * (PIP_SIZE.x + PIP_GAP), 0.0), PIP_SIZE)
		draw_rect(rect.grow(1.0), OUTLINE_COLOR)
		draw_rect(rect, FULL_COLOR if i < current_health else EMPTY_COLOR)


func _on_player_health_changed(current: int, maximum: int) -> void:
	current_health = current
	max_health = maximum
	queue_redraw()
