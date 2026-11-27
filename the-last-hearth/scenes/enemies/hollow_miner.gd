class_name HollowMiner
extends CharacterBody2D
## Hollow Miner: slow melee enemy. Idle -> Chase -> WindUp (visible) -> Attack -> Recover.
## Touching its body never hurts; only the attack after the wind-up does.

enum State { IDLE, CHASE, WINDUP, ATTACK, RECOVER, HURT, DEAD }

const WINDUP_COLOR: Color = Color(1.0, 0.35, 0.2)
const WINDUP_BLINK_INTERVAL: float = 0.1
const HURT_FLASH_COLOR: Color = Color(3.0, 3.0, 3.0)
const HURT_FLASH_TIME: float = 0.08
const DEATH_FADE_TIME: float = 0.3

@export var data: EnemyData

var state: State = State.IDLE
var target: Node2D = null

var _state_time: float = 0.0
var _flash_time_left: float = 0.0
var _attack_direction: Vector2 = Vector2.RIGHT

@onready var _sprite: Sprite2D = %Sprite
@onready var _body_shape: CollisionShape2D = %BodyShape
@onready var _health: HealthComponent = %Health
@onready var _hurtbox: HurtboxComponent = %Hurtbox
@onready var _attack_pivot: Node2D = %AttackPivot
@onready var _attack_sprite: Sprite2D = %AttackSprite
@onready var _attack_hitbox: HitboxComponent = %AttackHitbox


func _ready() -> void:
	add_to_group(&"enemies")
	_health.reset(data.max_health)
	_health.died.connect(_on_died)
	_hurtbox.hurt.connect(_on_hurt)
	_attack_hitbox.attacker = self
	_attack_hitbox.damage = data.attack_damage
	_attack_hitbox.knockback_force = data.attack_knockback
	_attack_sprite.visible = false


func set_target(new_target: Node2D) -> void:
	target = new_target


func _physics_process(delta: float) -> void:
	_state_time += delta
	_flash_time_left = maxf(_flash_time_left - delta, 0.0)
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			if _target_distance() <= data.detection_radius:
				_change_state(State.CHASE)
		State.CHASE:
			var distance: float = _target_distance()
			if distance > data.lose_interest_radius:
				_change_state(State.IDLE)
			elif distance <= data.attack_range:
				_start_windup()
			else:
				velocity = global_position.direction_to(target.global_position) * data.move_speed
		State.WINDUP:
			velocity = Vector2.ZERO
			if _state_time >= data.windup_time:
				_start_attack()
		State.ATTACK:
			velocity = Vector2.ZERO
			if _state_time >= data.attack_active_time:
				_attack_sprite.visible = false
				_change_state(State.RECOVER)
		State.RECOVER:
			velocity = Vector2.ZERO
			if _state_time >= data.attack_recover_time:
				_change_state(State.CHASE)
		State.HURT:
			velocity = velocity.move_toward(Vector2.ZERO, data.knockback_friction * delta)
			if _state_time >= data.hurt_stun_time:
				_change_state(State.CHASE)
		State.DEAD:
			velocity = Vector2.ZERO
	move_and_slide()
	_update_tint()


func is_dead() -> bool:
	return state == State.DEAD


func _target_distance() -> float:
	if target == null or not is_instance_valid(target):
		return INF
	return global_position.distance_to(target.global_position)


func _change_state(new_state: State) -> void:
	state = new_state
	_state_time = 0.0


func _start_windup() -> void:
	_attack_direction = global_position.direction_to(target.global_position)
	if _attack_direction == Vector2.ZERO:
		_attack_direction = Vector2.RIGHT
	_attack_pivot.rotation = _attack_direction.angle()
	_change_state(State.WINDUP)


func _start_attack() -> void:
	_attack_sprite.visible = true
	_attack_hitbox.activate(data.attack_active_time)
	_change_state(State.ATTACK)


func _update_tint() -> void:
	if _flash_time_left > 0.0:
		_sprite.modulate = HURT_FLASH_COLOR
	elif state == State.WINDUP and int(_state_time / WINDUP_BLINK_INTERVAL) % 2 == 0:
		_sprite.modulate = WINDUP_COLOR
	elif state != State.DEAD:
		_sprite.modulate = Color.WHITE


func _on_hurt(_damage: int, knockback: Vector2, _source: Node2D) -> void:
	if state == State.DEAD:
		return
	_flash_time_left = HURT_FLASH_TIME
	_attack_hitbox.deactivate()
	_attack_sprite.visible = false
	velocity = knockback
	_change_state(State.HURT)


func _on_died() -> void:
	_change_state(State.DEAD)
	_attack_hitbox.deactivate()
	_attack_sprite.visible = false
	_body_shape.set_deferred(&"disabled", true)
	_hurtbox.set_deferred(&"monitorable", false)
	_sprite.modulate = HURT_FLASH_COLOR
	EventBus.enemy_died.emit(data, global_position)
	var tween: Tween = create_tween()
	tween.tween_property(_sprite, "modulate", Color(1.0, 1.0, 1.0, 0.0), DEATH_FADE_TIME)
	tween.tween_callback(queue_free)
