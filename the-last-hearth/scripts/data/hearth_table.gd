class_name HearthTable
extends Resource
## All Hearth Flame levels, in order (levels[0] is level 1, the starting level).
## Instance: data/hearth/hearth_levels.tres. Effects of a level apply to every level above it too.

@export var levels: Array[HearthLevelData] = []
## Item paid with gold to kindle a level (Ember Coal).
@export var cost_item: ItemData


func max_level() -> int:
	return levels.size()


## Data of a level (1-based), or null when out of range.
func get_level(level: int) -> HearthLevelData:
	if level < 1 or level > levels.size():
		return null
	return levels[level - 1]


func cook_batch_size(level: int) -> int:
	var size: int = 1
	for data: HearthLevelData in _reached(level):
		size += data.cook_batch_bonus
	return size


func cook_time_factor(level: int) -> float:
	var factor: float = 1.0
	for data: HearthLevelData in _reached(level):
		factor *= data.cook_time_factor
	return factor


func customer_slots(level: int) -> int:
	var slots: int = 1
	for data: HearthLevelData in _reached(level):
		slots += data.customer_slot_bonus
	return slots


func max_health_bonus(level: int) -> int:
	var bonus: int = 0
	for data: HearthLevelData in _reached(level):
		bonus += data.max_health_bonus
	return bonus


func dodge_distance_factor(level: int) -> float:
	var factor: float = 1.0
	for data: HearthLevelData in _reached(level):
		factor *= data.dodge_distance_factor
	return factor


## Letter keys revealed up to `level`, in order.
func letters_up_to(level: int) -> Array[StringName]:
	var keys: Array[StringName] = []
	for data: HearthLevelData in _reached(level):
		if data.letter_key != &"":
			keys.append(data.letter_key)
	return keys


func _reached(level: int) -> Array[HearthLevelData]:
	return levels.slice(0, clampi(level, 0, levels.size()))
