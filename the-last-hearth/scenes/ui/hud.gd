extends Control
## Minimal HUD: health pips (top-left) and the Cave Mushroom count in the bag. No words, so nothing to translate.

const PIP_SIZE: Vector2 = Vector2(7.0, 7.0)
const PIP_GAP: float = 2.0
const FULL_COLOR: Color = Color(0.85, 0.27, 0.2)
const EMPTY_COLOR: Color = Color(0.2, 0.16, 0.16)
const OUTLINE_COLOR: Color = Color(0.0862745, 0.0784314, 0.109804)

## Item counted next to the icon (Cave Mushroom in the MVP).
@export var tracked_item: ItemData

var current_health: int = 0
var max_health: int = 0

@onready var _item_icon: TextureRect = %ItemIcon
@onready var _item_count: Label = %ItemCount


func _ready() -> void:
	EventBus.player_health_changed.connect(_on_player_health_changed)
	GameState.bag.changed.connect(_refresh_item_count)
	_item_icon.texture = tracked_item.icon if tracked_item != null else null
	_refresh_item_count()


func get_item_count_text() -> String:
	return _item_count.text


func _draw() -> void:
	for i: int in max_health:
		var rect: Rect2 = Rect2(Vector2(i * (PIP_SIZE.x + PIP_GAP), 0.0), PIP_SIZE)
		draw_rect(rect.grow(1.0), OUTLINE_COLOR)
		draw_rect(rect, FULL_COLOR if i < current_health else EMPTY_COLOR)


func _refresh_item_count() -> void:
	var amount: int = GameState.bag.count_of(tracked_item) if tracked_item != null else 0
	_item_count.text = "×%d" % amount


func _on_player_health_changed(current: int, maximum: int) -> void:
	current_health = current
	max_health = maximum
	queue_redraw()
