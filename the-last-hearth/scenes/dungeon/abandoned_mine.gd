extends Level
## Abandoned Mine graybox. Four rooms (R1–R4), each with one possible coal vein spot.
## Every visit keeps a random 2–3 of those veins, so the veins are always in different rooms.

@export var min_veins: int = 2
@export var max_veins: int = 3


func _ready() -> void:
	_choose_veins()
	super._ready()


func get_veins() -> Array[OreVein]:
	var veins: Array[OreVein] = []
	for child: Node in _entities.get_children():
		var vein: OreVein = child as OreVein
		if vein != null and not vein.is_queued_for_deletion():
			veins.append(vein)
	return veins


func _choose_veins() -> void:
	var spots: Array[OreVein] = get_veins()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var keep: int = mini(rng.randi_range(min_veins, max_veins), spots.size())
	# Fisher–Yates with our own rng, then drop the spots past `keep`.
	for i: int in range(spots.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var swap: OreVein = spots[i]
		spots[i] = spots[j]
		spots[j] = swap
	for i: int in range(keep, spots.size()):
		_entities.remove_child(spots[i])
		spots[i].queue_free()
