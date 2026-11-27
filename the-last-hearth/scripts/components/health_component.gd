class_name HealthComponent
extends Node
## Hit points of an entity. Damage normally arrives through a HurtboxComponent.

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 3

var current_health: int = 0


func _ready() -> void:
	current_health = max_health


func take_damage(amount: int) -> void:
	if amount <= 0 or is_dead():
		return
	current_health = maxi(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()


func heal(amount: int) -> void:
	if amount <= 0 or is_dead():
		return
	current_health = mini(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


## Restores full health, also after death.
func reset(new_max_health: int = -1) -> void:
	if new_max_health > 0:
		max_health = new_max_health
	current_health = max_health
	health_changed.emit(current_health, max_health)


func is_dead() -> bool:
	return current_health <= 0
