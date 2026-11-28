class_name EconomySim
extends RefCounted
## Expected-value simulation of the day loop, used to check the Hearth Flame pacing (VS-E1).
## Reads the real data: Hearth levels, Weary Traveler payment, the stew recipe, the mine layout
## (pre-placed mushrooms, miners, vein spots), miner loot and vein loot. Only the player behaviour
## is assumed (a profile). Numbers are averages, not a random playthrough.
## Report: godot --headless --path . -s res://tests/economy_report.gd   (docs/ECONOMY_BALANCING.md)

const MINE_SCENE: String = "res://scenes/dungeon/abandoned_mine.tscn"
const CUSTOMER_PATH: String = "res://data/customers/weary_traveler.tres"
const RECIPE_PATH: String = "res://data/recipes/mushroom_stew.tres"
const ENEMY_PATH: String = "res://data/enemies/hollow_miner.tres"
const VEIN_SCENE: String = "res://scenes/dungeon/ore_vein.tscn"

## Player behaviour per run.
## kill_rate: share of the miners killed. vein_rate: share of the veins broken.
## death_rate: chance a run ends in death (the bag is lost). eat_stew: eats one spare stew per run.
const PROFILES: Dictionary[StringName, Dictionary] = {
	&"normal": {"kill_rate": 0.6, "vein_rate": 1.0, "death_rate": 0.1, "eat_stew": true},
	&"slow": {"kill_rate": 0.4, "vein_rate": 0.8, "death_rate": 0.25, "eat_stew": true},
	&"skilled": {"kill_rate": 0.9, "vein_rate": 1.0, "death_rate": 0.0, "eat_stew": true},
}

var table: HearthTable = load("res://data/hearth/hearth_levels.tres") as HearthTable
var payment: int = 0
var mushrooms_per_stew: int = 0
var preplaced_mushrooms: int = 0
var miners: int = 0
var miner_mushroom_drop: float = 0.0
var avg_veins: float = 0.0
var avg_coal_per_vein: float = 0.0


func _init() -> void:
	payment = (load(CUSTOMER_PATH) as CustomerData).payment
	var recipe: RecipeData = load(RECIPE_PATH) as RecipeData
	mushrooms_per_stew = recipe.ingredients[0].count / recipe.result_count
	var mushroom: ItemData = recipe.ingredients[0].item
	for entry: LootEntry in (load(ENEMY_PATH) as EnemyData).loot:
		if entry.item == mushroom:
			miner_mushroom_drop += entry.chance * (entry.min_count + entry.max_count) / 2.0
	var mine: Node = (load(MINE_SCENE) as PackedScene).instantiate()
	for child: Node in mine.get_node("Entities").get_children():
		if child is Pickup and (child as Pickup).item == mushroom:
			preplaced_mushrooms += (child as Pickup).count
		elif child.name.begins_with("Miner"):
			miners += 1
	var vein_spots: int = mine.get_node("Entities").get_children().filter(func(c: Node) -> bool: return c is OreVein).size()
	avg_veins = minf((int(mine.get("min_veins")) + int(mine.get("max_veins"))) / 2.0, vein_spots)
	mine.free()
	var vein: OreVein = (load(VEIN_SCENE) as PackedScene).instantiate() as OreVein
	avg_coal_per_vein = vein.loot.chance * (vein.loot.min_count + vein.loot.max_count) / 2.0
	vein.free()


## Mushrooms and coal brought back per run on average (deaths included).
func run_yield(profile: Dictionary) -> Dictionary:
	var kept: float = 1.0 - float(profile["death_rate"])
	var mushrooms: float = (preplaced_mushrooms + miners * float(profile["kill_rate"]) * miner_mushroom_drop) * kept
	var coal: float = avg_veins * float(profile["vein_rate"]) * avg_coal_per_vein * kept
	return {"mushrooms": mushrooms, "coal": coal}


## Day loop: day 1 starts in the tavern with nothing; each later day starts after a run.
## In the tavern: cook every stew possible, serve each open seat, eat one spare stew, kindle when
## both costs are met. Returns {"level_day": {level: day}, "days": [per-day rows]}.
func simulate(profile: Dictionary, max_days: int = 30) -> Dictionary:
	var per_run: Dictionary = run_yield(profile)
	var gold: float = 0.0
	var coal: float = 0.0
	var stews: float = 0.0
	var level: int = 1
	var level_day: Dictionary[int, int] = {1: 1}
	var rows: Array[Dictionary] = []
	for day: int in range(1, max_days + 1):
		if day > 1:
			stews += float(per_run["mushrooms"]) / mushrooms_per_stew
			coal += float(per_run["coal"])
		var served: float = minf(table.customer_slots(level), stews)
		stews -= served
		var earned: float = served * payment
		gold += earned
		if bool(profile["eat_stew"]) and stews >= 1.0 and day > 1:
			stews -= 1.0
		var next: HearthLevelData = table.get_level(level + 1)
		while next != null and gold >= next.gold_cost and coal >= next.ember_cost:
			gold -= next.gold_cost
			coal -= next.ember_cost
			level = next.level
			level_day[level] = day
			next = table.get_level(level + 1)
		rows.append({"day": day, "earned": earned, "gold": gold, "coal": coal, "level": level})
		if level >= table.max_level():
			break
	return {"level_day": level_day, "days": rows}
