class_name WeaponData
extends ItemData
## Melee weapon stats. All values are starting values to tune by playtesting.

@export var damage: int = 1
## Seconds between swings.
@export var attack_cooldown: float = 0.35
## Knockback speed (px/s) given to the target.
@export var knockback: float = 160.0
## Seconds the hitbox is active during a swing.
@export var hit_active_time: float = 0.1
## Seconds the swing visual is shown and movement is slowed.
@export var swing_duration: float = 0.15
## Movement speed multiplier while swinging.
@export var swing_move_factor: float = 0.4
## Freeze of all entities when the swing lands (hit-stop).
@export var hit_stop_time: float = 0.05
