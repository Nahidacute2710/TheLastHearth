class_name Player
extends CharacterBody2D
## Player body: movement, attack and dodge input, health, hurt reaction and death.
## Stats come from PlayerData. Origin is at the feet so y-sorting works.

## A swing of the equipped weapon hit a hurtbox (the level uses this for hit-stop).
signal attack_landed(hurtbox: HurtboxComponent)
## Health reached 0. The level handles the return to the tavern.
signal died

enum State { NORMAL, DODGE, KNOCKBACK, DEAD }

const INVULNERABLE_BLINK_INTERVAL: float = 0.08
const DODGE_ALPHA: float = 0.5
const DEAD_TINT: Color = Color(0.55, 0.25, 0.25)

@export var data: PlayerData

var state: State = State.NORMAL

var _state_time_left: float = 0.0
var _dodge_cooldown_left: float = 0.0
var _dodge_velocity: Vector2 = Vector2.ZERO
var _blink_time: float = 0.0

@onready var _camera: Camera2D = %Camera
@onready var _attack: PlayerAttack = %WeaponPivot
@onready var _sprite: Sprite2D = %Sprite
@onready var _health: HealthComponent = %Health
@onready var _hurtbox: HurtboxComponent = %Hurtbox


func _ready() -> void:
	_attack.attack_landed.connect(_on_attack_landed)
	_health.health_changed.connect(_on_health_changed)
	_health.died.connect(_on_died)
	_hurtbox.hurt.connect(_on_hurt)
	EventBus.max_health_buff_changed.connect(_on_max_health_buff_changed)
	_health.reset(get_max_health())


func _physics_process(delta: float) -> void:
	_state_time_left = maxf(_state_time_left - delta, 0.0)
	_dodge_cooldown_left = maxf(_dodge_cooldown_left - delta, 0.0)
	match state:
		State.NORMAL:
			_move(delta)
		State.DODGE:
			velocity = _dodge_velocity
			if _state_time_left <= 0.0:
				state = State.NORMAL
		State.KNOCKBACK:
			velocity = velocity.move_toward(Vector2.ZERO, data.friction * delta)
			if _state_time_left <= 0.0:
				state = State.NORMAL
		State.DEAD:
			velocity = Vector2.ZERO
	move_and_slide()
	_update_visual(delta)


func _unhandled_input(event: InputEvent) -> void:
	if state == State.DEAD:
		return
	if event.is_action_pressed(&"attack"):
		attack_towards(get_global_mouse_position() - _attack.global_position)
	elif event.is_action_pressed(&"dodge"):
		var direction: Vector2 = Input.get_vector(&"movement_left", &"movement_right", &"movement_up", &"movement_down")
		if direction == Vector2.ZERO:
			direction = get_global_mouse_position() - _attack.global_position
		dodge(direction)


## Swings the equipped weapon toward a direction. Returns true when a swing started.
func attack_towards(direction: Vector2) -> bool:
	if state != State.NORMAL:
		return false
	return _attack.attack_towards(direction)


## Short dash with i-frames. Returns true when the dodge started.
func dodge(direction: Vector2) -> bool:
	if state != State.NORMAL or _dodge_cooldown_left > 0.0:
		return false
	var dash_direction: Vector2 = direction.normalized() if direction != Vector2.ZERO else Vector2.DOWN
	_dodge_velocity = dash_direction * data.dodge_speed
	state = State.DODGE
	_state_time_left = data.dodge_duration
	_dodge_cooldown_left = data.dodge_cooldown
	_hurtbox.start_invulnerability(data.dodge_invulnerability)
	EventBus.sfx_requested.emit(&"dodge")
	return true


func is_dead() -> bool:
	return state == State.DEAD


func get_health() -> HealthComponent:
	return _health


## Base max health plus the food buff from GameState.
func get_max_health() -> int:
	return data.max_health + GameState.max_health_buff


func heal_full() -> void:
	if state != State.DEAD:
		_health.reset()


func set_god_mode(enabled: bool) -> void:
	_hurtbox.debug_invulnerable = enabled


func is_god_mode() -> bool:
	return _hurtbox.debug_invulnerable


## Called by the room that owns the player. Rect is in pixels, in the room's coordinates.
func set_camera_limits(rect: Rect2i) -> void:
	_camera.limit_left = rect.position.x
	_camera.limit_top = rect.position.y
	_camera.limit_right = rect.end.x
	_camera.limit_bottom = rect.end.y


func _move(delta: float) -> void:
	var direction: Vector2 = Input.get_vector(&"movement_left", &"movement_right", &"movement_up", &"movement_down")
	var speed: float = data.max_speed
	if _attack.is_swinging() and GameState.equipped_weapon != null:
		speed *= GameState.equipped_weapon.swing_move_factor
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, data.acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, data.friction * delta)


func _update_visual(delta: float) -> void:
	_blink_time += delta
	if state == State.DEAD:
		_sprite.modulate = DEAD_TINT
	elif state == State.DODGE:
		_sprite.modulate = Color(1.0, 1.0, 1.0, DODGE_ALPHA)
	elif _hurtbox.is_invulnerable() and not _hurtbox.debug_invulnerable:
		var visible_phase: bool = int(_blink_time / INVULNERABLE_BLINK_INTERVAL) % 2 == 0
		_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0 if visible_phase else 0.3)
	else:
		_sprite.modulate = Color.WHITE


func _on_attack_landed(hurtbox: HurtboxComponent) -> void:
	EventBus.sfx_requested.emit(&"hit")
	attack_landed.emit(hurtbox)


func _on_health_changed(current: int, maximum: int) -> void:
	EventBus.player_health_changed.emit(current, maximum)


func _on_hurt(_damage: int, knockback: Vector2, _source: Node2D) -> void:
	if state == State.DEAD:
		return
	EventBus.sfx_requested.emit(&"hit")
	_hurtbox.start_invulnerability(data.hurt_invulnerability)
	velocity = knockback
	state = State.KNOCKBACK
	_state_time_left = data.hurt_knockback_time


## Buff changes only happen in the tavern (eating) or on the way back, so a full reset is safe.
func _on_max_health_buff_changed(_amount: int) -> void:
	if state != State.DEAD:
		_health.reset(get_max_health())


func _on_died() -> void:
	state = State.DEAD
	_sprite.rotation_degrees = 90.0
	_hurtbox.set_deferred(&"monitorable", false)
	died.emit()
	EventBus.player_died.emit()
