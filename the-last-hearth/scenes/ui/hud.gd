extends Control
## Minimal HUD: health pips (top-left; pips from the food buff are drawn in another colour) and the
## Cave Mushroom count in the bag. No words, so nothing to translate.

const PIP_SIZE: Vector2 = Vector2(7.0, 7.0)
const PIP_GAP: float = 2.0
const FULL_COLOR: Color = Color(0.85, 0.27, 0.2)
const EMPTY_COLOR: Color = Color(0.2, 0.16, 0.16)
const BUFF_COLOR: Color = Color(0.95, 0.7, 0.25)
const BUFF_EMPTY_COLOR: Color = Color(0.3, 0.24, 0.12)
const OUTLINE_COLOR: Color = Color(0.0862745, 0.0784314, 0.109804)

## Item counted next to the icon (Cave Mushroom in the MVP).
@export var tracked_item: ItemData

var current_health: int = 0
var max_health: int = 0
## How many of the last pips come from the food buff.
var buff_pips: int = 0

@onready var _item_icon: TextureRect = %ItemIcon
@onready var _item_count: Label = %ItemCount


func _ready() -> void:
	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.max_health_buff_changed.connect(_on_buff_changed)
	buff_pips = GameState.max_health_buff
	GameState.bag.changed.connect(_refresh_item_count)
	_item_icon.texture = tracked_item.icon if tracked_item != null else null
	_refresh_item_count()


func get_item_count_text() -> String:
	return _item_count.text


func _draw() -> void:
	for i: int in max_health:
		var rect: Rect2 = Rect2(Vector2(i * (PIP_SIZE.x + PIP_GAP), 0.0), PIP_SIZE)
		draw_rect(rect.grow(1.0), OUTLINE_COLOR)
		var is_buff: bool = i >= max_health - buff_pips
		if i < current_health:
			draw_rect(rect, BUFF_COLOR if is_buff else FULL_COLOR)
		else:
			draw_rect(rect, BUFF_EMPTY_COLOR if is_buff else EMPTY_COLOR)


func _refresh_item_count() -> void:
	var amount: int = GameState.bag.count_of(tracked_item) if tracked_item != null else 0
	_item_count.text = "×%d" % amount


func _on_player_health_changed(current: int, maximum: int) -> void:
	current_health = current
	max_health = maximum
	queue_redraw()


func _on_buff_changed(amount: int) -> void:
	buff_pips = amount
	queue_redraw()
