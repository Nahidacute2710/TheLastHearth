class_name Pickup
extends Area2D
## Item lying on the ground. Touching it puts it in the bag (GameState.bag).
## Stays (with the remainder) when the bag is full.

const BOB_HEIGHT: float = 1.5
const BOB_SPEED: float = 3.0

@export var item: ItemData
@export var count: int = 1

var _time: float = 0.0

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	_sprite.texture = item.icon if item != null else null
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	_sprite.position.y = -8.0 - absf(sin(_time * BOB_SPEED)) * BOB_HEIGHT


func _on_body_entered(body: Node2D) -> void:
	if not body is Player or item == null:
		return
	var left: int = GameState.bag.add(item, count)
	if left < count:
		EventBus.sfx_requested.emit(&"pickup")
	if left == 0:
		set_deferred(&"monitoring", false)
		queue_free()
	else:
		count = left
