extends Node
## Boot scene root. Lives for the whole game; SceneRouter swaps levels inside LevelRoot.

@onready var _level_root: Node2D = %LevelRoot


func _ready() -> void:
	SceneRouter.start(_level_root, SceneRouter.TAVERN)
