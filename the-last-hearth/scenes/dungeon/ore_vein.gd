class_name OreVein
extends StaticBody2D
## A coal vein in the mine. Solid like a rock; the pickaxe hits its own hurtbox (EnemyHurtbox layer,
## so the player's weapon reaches it, but enemy attacks, which only look at PlayerHurtbox, never do).
## Hitting a vein only damages the vein: it is not an enemy, emits no enemy signal and drops no enemy loot.
## Breaks after a few hits and drops its loot (Ember Coal) as single pickups around it.

const PICKUP_SCENE: PackedScene = preload("res://scenes/items/pickup.tscn")
const FLASH_TIME: float = 0.08
const SHAKE_PIXELS: float = 1.0
## Random offset of the dropped pickups (px).
const DROP_SCATTER: float = 10.0

## What breaking the vein drops (Ember Coal 2–3).
@export var loot: LootEntry
## Room id (R1..R4) used to keep veins in different rooms.
@export var room: StringName = &""

var _flash_left: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var _sprite: Sprite2D = %Sprite
@onready var _health: HealthComponent = %Health
@onready var _hurtbox: HurtboxComponent = %Hurtbox


func _ready() -> void:
	_rng.randomize()
	_hurtbox.hurt.connect(_on_hurt)
	_health.died.connect(_on_broken)


func _process(delta: float) -> void:
	if _flash_left <= 0.0:
		return
	_flash_left -= delta
	if _flash_left <= 0.0:
		_sprite.modulate = Color.WHITE
		_sprite.position = Vector2.ZERO


func get_hits_left() -> int:
	return _health.current_health


func is_broken() -> bool:
	return _health.is_dead()


func _on_hurt(_damage: int, knockback: Vector2, _source: Node2D) -> void:
	_flash_left = FLASH_TIME
	_sprite.modulate = Color(1.6, 1.3, 1.0)
	_sprite.position = knockback.normalized() * SHAKE_PIXELS
	if not _health.is_dead():
		EventBus.sfx_requested.emit(&"ore_hit")


func _on_broken() -> void:
	EventBus.sfx_requested.emit(&"ore_break")
	_hurtbox.set_deferred(&"monitorable", false)
	var amount: int = loot.roll(_rng) if loot != null else 0
	var parent: Node = get_parent()
	for i: int in amount:
		var pickup: Pickup = PICKUP_SCENE.instantiate() as Pickup
		pickup.item = loot.item
		pickup.count = 1
		pickup.position = position + Vector2(_rng.randf_range(-DROP_SCATTER, DROP_SCATTER), _rng.randf_range(2.0, DROP_SCATTER))
		parent.add_child.call_deferred(pickup)
	queue_free()
