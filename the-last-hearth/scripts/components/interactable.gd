class_name Interactable
extends Area2D
## Something the player can interact with. Sits on layer 6 (Interactable) with mask 2 (Player),
## so it detects the player body and reports it on EventBus. The player's Interactor picks the nearest.

signal interacted(actor: Node2D)

@export var prompt_key: StringName = &""
@export var enabled: bool = true


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _exit_tree() -> void:
	EventBus.interactable_unavailable.emit(self)


func interact(actor: Node2D) -> void:
	if enabled:
		interacted.emit(actor)


func _on_body_entered(_body: Node2D) -> void:
	EventBus.interactable_available.emit(self)


func _on_body_exited(_body: Node2D) -> void:
	EventBus.interactable_unavailable.emit(self)
