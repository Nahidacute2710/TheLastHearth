class_name HearthLevelData
extends Resource
## One level of the Hearth Flame (Ngọn Lửa Gốc). Costs are paid to reach this level.
## Effects are what this level adds on top of the levels below it.

@export var level: int = 1
@export var gold_cost: int = 0
## Ember Coal taken from the stash.
@export var ember_cost: int = 0
## Short text of what this level unlocks (panel, toast).
@export var unlock_key: StringName = &""
## Part of the previous owner's letter revealed when this level is reached (empty = none).
@export var letter_key: StringName = &""

@export_group("Effects")
## Extra dishes per cooking batch (each still uses the full recipe).
@export var cook_batch_bonus: int = 0
## Cook time multiplier (1 = unchanged).
@export var cook_time_factor: float = 1.0
## Extra customer seats (a second Weary Traveler...).
@export var customer_slot_bonus: int = 0
## Permanent extra max health.
@export var max_health_bonus: int = 0
## Dodge speed multiplier (same duration, so the dash goes further).
@export var dodge_distance_factor: float = 1.0
