class_name PlayerData
extends Resource
## Player stats. Instance: data/characters/innkeeper.tres. All numbers are starting values.

@export_group("Movement")
@export var max_speed: float = 80.0
@export var acceleration: float = 800.0
@export var friction: float = 1000.0

@export_group("Health")
@export var max_health: int = 5
## Invulnerability after taking a hit (s).
@export var hurt_invulnerability: float = 0.8
## Seconds the player loses control while knocked back.
@export var hurt_knockback_time: float = 0.15
## Pause between dying and the fade back to the tavern (s).
@export var death_delay: float = 0.6

@export_group("Dodge")
@export var dodge_speed: float = 220.0
@export var dodge_duration: float = 0.18
@export var dodge_invulnerability: float = 0.22
@export var dodge_cooldown: float = 0.6
