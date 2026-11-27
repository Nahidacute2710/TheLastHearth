class_name LootEntry
extends Resource
## One possible drop: `item` with probability `chance`, between min_count and max_count.

@export var item: ItemData
@export_range(0.0, 1.0) var chance: float = 1.0
@export var min_count: int = 1
@export var max_count: int = 1


## Returns how many to drop (0 when the roll fails).
func roll(rng: RandomNumberGenerator) -> int:
	if item == null or rng.randf() >= chance:
		return 0
	return rng.randi_range(min_count, max_count)
