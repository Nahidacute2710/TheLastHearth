class_name EnemyData
extends Resource
## Definition of an enemy type. Instances live in data/enemies/. All numbers are starting values.

@export var id: StringName = &""
@export var name_key: StringName = &""
@export var max_health: int = 3
## Chase speed in px/s.
@export var move_speed: float = 38.0
## Starts chasing when the target is closer than this (px).
@export var detection_radius: float = 120.0
## Gives up when the target is farther than this (px).
@export var lose_interest_radius: float = 200.0
## Starts the wind-up when the target is closer than this (px, feet to feet).
@export var attack_range: float = 22.0
## Visible wind-up before the hit (s). The only way this enemy deals damage.
@export var windup_time: float = 0.6
## Seconds the attack hitbox is active.
@export var attack_active_time: float = 0.12
## Pause after an attack before chasing again (s).
@export var attack_recover_time: float = 0.6
@export var attack_damage: int = 1
## Knockback speed (px/s) given to the player.
@export var attack_knockback: float = 140.0
## Stun after being hit (s). Being hit cancels the wind-up.
@export var hurt_stun_time: float = 0.25
## Deceleration of knockback (px/s²).
@export var knockback_friction: float = 900.0
