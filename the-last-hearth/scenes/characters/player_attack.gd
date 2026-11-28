class_name PlayerAttack
extends Node2D
## Weapon pivot of the player. Rotates toward the aim direction, shows the swing placeholder
## and drives the hitbox using the equipped WeaponData from GameState.

signal attack_landed(hurtbox: HurtboxComponent)

var _cooldown_left: float = 0.0
var _swing_left: float = 0.0

@onready var _hitbox: HitboxComponent = $Hitbox
@onready var _swing_sprite: Sprite2D = $SwingSprite


func _ready() -> void:
	_hitbox.attacker = owner as Node2D
	_hitbox.hit_landed.connect(_on_hit_landed)
	_swing_sprite.visible = false


func _physics_process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if _swing_left > 0.0:
		_swing_left -= delta
		if _swing_left <= 0.0:
			_swing_sprite.visible = false


## Returns true when a swing started.
func attack_towards(direction: Vector2) -> bool:
	var weapon: WeaponData = GameState.equipped_weapon
	if weapon == null or _cooldown_left > 0.0:
		return false
	rotation = (direction if direction != Vector2.ZERO else Vector2.RIGHT).angle()
	_hitbox.damage = weapon.damage
	_hitbox.knockback_force = weapon.knockback
	_hitbox.activate(weapon.hit_active_time)
	_swing_left = weapon.swing_duration
	_swing_sprite.visible = true
	_cooldown_left = weapon.attack_cooldown
	EventBus.sfx_requested.emit(&"swing")
	return true


func is_swinging() -> bool:
	return _swing_left > 0.0


func _on_hit_landed(hurtbox: HurtboxComponent) -> void:
	attack_landed.emit(hurtbox)
