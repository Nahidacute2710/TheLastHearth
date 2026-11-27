class_name Player
extends CharacterBody2D
## Top-down 8-direction movement with short acceleration and deceleration.
## Origin is at the feet so y-sorting works in later milestones.

@export var max_speed: float = 80.0
@export var acceleration: float = 800.0
@export var friction: float = 1000.0

@onready var _camera: Camera2D = %Camera


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector(&"movement_left", &"movement_right", &"movement_up", &"movement_down")
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()


## Called by the room that owns the player. Rect is in pixels, in the room's coordinates.
func set_camera_limits(rect: Rect2i) -> void:
	_camera.limit_left = rect.position.x
	_camera.limit_top = rect.position.y
	_camera.limit_right = rect.end.x
	_camera.limit_bottom = rect.end.y
