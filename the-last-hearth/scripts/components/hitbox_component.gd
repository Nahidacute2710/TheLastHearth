class_name HitboxComponent
extends Area2D
## Attack area. Empty layer, mask = the opponent hurtbox layer. Only monitors while an attack
## is active, and hits each hurtbox at most once per activation.

signal hit_landed(hurtbox: HurtboxComponent)

@export var damage: int = 1
@export var knockback_force: float = 100.0

## Node whose position defines the knockback origin (usually the attacker body).
var attacker: Node2D = null

var _hit_this_activation: Array[HurtboxComponent] = []
var _active_time_left: float = 0.0


func _ready() -> void:
	monitoring = false
	monitorable = false
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if _active_time_left > 0.0:
		_active_time_left -= delta
		if _active_time_left <= 0.0:
			deactivate()


func activate(duration: float) -> void:
	_hit_this_activation.clear()
	_active_time_left = duration
	set_deferred(&"monitoring", true)


func deactivate() -> void:
	_active_time_left = 0.0
	set_deferred(&"monitoring", false)


func is_active() -> bool:
	return _active_time_left > 0.0


func _on_area_entered(area: Area2D) -> void:
	var hurtbox: HurtboxComponent = area as HurtboxComponent
	if hurtbox == null or _hit_this_activation.has(hurtbox) or not is_active():
		return
	_hit_this_activation.append(hurtbox)
	var origin: Vector2 = attacker.global_position if attacker != null else global_position
	var direction: Vector2 = (hurtbox.global_position - origin).normalized()
	if hurtbox.receive_hit(damage, direction * knockback_force, attacker):
		hit_landed.emit(hurtbox)
