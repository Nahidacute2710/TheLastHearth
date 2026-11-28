class_name HurtboxComponent
extends Area2D
## Area that receives hits. Layer 4 (PlayerHurtbox) or 5 (EnemyHurtbox), empty mask:
## hitboxes detect hurtboxes, never the other way around.
## Invulnerability (hurt i-frames, dodge) turns the hurtbox off so hitboxes cannot see it.

signal hurt(damage: int, knockback: Vector2, source: Node2D)

@export var health: HealthComponent
## Sound the attacker plays when its hit lands here (an ore vein clinks instead of the flesh hit).
@export var hit_sfx: StringName = &"hit"

## Debug god mode: never takes damage, independent of i-frames.
var debug_invulnerable: bool = false

var _invulnerable_time_left: float = 0.0


func _physics_process(delta: float) -> void:
	if _invulnerable_time_left > 0.0:
		_invulnerable_time_left -= delta
		if _invulnerable_time_left <= 0.0:
			_invulnerable_time_left = 0.0
			set_deferred(&"monitorable", true)


## Returns true when the hit was accepted.
func receive_hit(damage: int, knockback: Vector2, source: Node2D) -> bool:
	if is_invulnerable():
		return false
	if health != null:
		health.take_damage(damage)
	hurt.emit(damage, knockback, source)
	return true


## Starts or extends invulnerability. Shared by hurt i-frames and dodge.
func start_invulnerability(duration: float) -> void:
	if duration <= 0.0:
		return
	_invulnerable_time_left = maxf(_invulnerable_time_left, duration)
	set_deferred(&"monitorable", false)


func is_invulnerable() -> bool:
	return debug_invulnerable or _invulnerable_time_left > 0.0
