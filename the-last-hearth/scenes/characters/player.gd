class_name Player
extends CharacterBody2D
## Player body: top-down 8-direction movement and attack input.
## Origin is at the feet so y-sorting works.

## A swing of the equipped weapon hit a hurtbox (the level uses this for hit-stop).
signal attack_landed(hurtbox: HurtboxComponent)

@export var max_speed: float = 80.0
@export var acceleration: float = 800.0
@export var friction: float = 1000.0

@onready var _camera: Camera2D = %Camera
@onready var _attack: PlayerAttack = %WeaponPivot


func _ready() -> void:
	_attack.attack_landed.connect(_on_attack_landed)


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector(&"movement_left", &"movement_right", &"movement_up", &"movement_down")
	var speed: float = max_speed
	if _attack.is_swinging() and GameState.equipped_weapon != null:
		speed *= GameState.equipped_weapon.swing_move_factor
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"attack"):
		attack_towards(get_global_mouse_position() - _attack.global_position)


## Swings the equipped weapon toward a direction. Returns true when a swing started.
func attack_towards(direction: Vector2) -> bool:
	return _attack.attack_towards(direction)


## Called by the room that owns the player. Rect is in pixels, in the room's coordinates.
func set_camera_limits(rect: Rect2i) -> void:
	_camera.limit_left = rect.position.x
	_camera.limit_top = rect.position.y
	_camera.limit_right = rect.end.x
	_camera.limit_bottom = rect.end.y


func _on_attack_landed(hurtbox: HurtboxComponent) -> void:
	attack_landed.emit(hurtbox)
