extends Node2D
## A hatch, door or ladder that sends the player to another level.

@export var texture: Texture2D
@export var target_level: StringName = &""
@export var target_spawn: StringName = &""
@export var prompt_key: StringName = &""

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	_sprite.texture = texture
	_interactable.prompt_key = prompt_key
	_interactable.interacted.connect(_on_interacted)


func _on_interacted(_actor: Node2D) -> void:
	SceneRouter.go_to(target_level, target_spawn)
