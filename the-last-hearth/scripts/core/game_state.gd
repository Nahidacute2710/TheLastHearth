extends Node
## Session data: day, gold, bag, tavern stash, equipped gear.
## Bag = items picked up during a dungeon run. Stash = tavern storage (cooking reads from it).
## Rules (DECISION_LOG, CP-C): safe return moves the bag into the stash; death empties the bag
## except quest items; every return from the dungeon to the tavern starts a new day.

const BAG_SLOTS: int = 12
const STASH_SLOTS: int = 30

var equipped_weapon: WeaponData = null
var bag: Inventory = Inventory.new(BAG_SLOTS)
var stash: Inventory = Inventory.new(STASH_SLOTS)
var day: int = 1
var gold: int = 0
## Customer id -> last day it was served.
var customer_served_day: Dictionary[StringName, int] = {}

var _last_level_id: StringName = &""


func _ready() -> void:
	EventBus.level_changed.connect(_on_level_changed)
	EventBus.player_died.connect(_on_player_died)


func equip_weapon(weapon: WeaponData) -> void:
	equipped_weapon = weapon
	EventBus.weapon_equipped.emit(weapon)


## True when the item is equipped, in the bag or in the stash.
func owns_item_id(id: StringName) -> bool:
	if equipped_weapon != null and equipped_weapon.id == id:
		return true
	return bag.has_item_id(id) or stash.has_item_id(id)


func is_customer_served_today(customer_id: StringName) -> bool:
	return customer_served_day.get(customer_id, 0) >= day


func mark_customer_served(customer_id: StringName) -> void:
	customer_served_day[customer_id] = day
	EventBus.autosave_requested.emit()


func add_gold(amount: int) -> void:
	gold = maxi(gold + amount, 0)
	EventBus.gold_changed.emit(gold)


func advance_day() -> void:
	day += 1
	EventBus.day_changed.emit(day)


## Moves everything from the bag into the stash. Items that do not fit stay in the bag.
func store_bag_in_stash() -> void:
	for stack: ItemStack in bag.get_stacks():
		var not_stored: int = stash.add(stack.item, stack.count)
		var stored: int = stack.count - not_stored
		if stored > 0:
			bag.remove(stack.item, stored)


## Death penalty: the bag is lost except quest items. Equipped gear is kept.
func apply_death_penalty() -> void:
	bag.clear_except_quest_items()


## Clears all session data (new game, tests).
func reset_session() -> void:
	equipped_weapon = null
	bag.clear()
	stash.clear()
	day = 1
	gold = 0
	customer_served_day.clear()
	_last_level_id = &""


func _on_level_changed(level_id: StringName) -> void:
	var from_dungeon: bool = _last_level_id == SceneRouter.DUNGEON
	_last_level_id = level_id
	if from_dungeon and level_id == SceneRouter.TAVERN:
		_report_stored(_store_and_count())
		advance_day()
		EventBus.autosave_requested.emit()


func _store_and_count() -> Dictionary[ItemData, int]:
	var before: Dictionary[ItemData, int] = bag.get_totals()
	store_bag_in_stash()
	var after: Dictionary[ItemData, int] = bag.get_totals()
	var moved: Dictionary[ItemData, int] = {}
	for item: ItemData in before:
		var amount: int = before[item] - after.get(item, 0)
		if amount > 0:
			moved[item] = amount
	return moved


func _report_stored(moved: Dictionary[ItemData, int]) -> void:
	for item: ItemData in moved:
		EventBus.items_stored.emit(item, moved[item])


func _on_player_died() -> void:
	apply_death_penalty()


## Saved data (see SaveManager). The bag is not saved: saves only happen in the tavern, where it is empty.
func to_dict() -> Dictionary:
	var served: Dictionary = {}
	for customer_id: StringName in customer_served_day:
		served[String(customer_id)] = customer_served_day[customer_id]
	return {
		"day": day,
		"gold": gold,
		"equipped_weapon": String(equipped_weapon.id) if equipped_weapon != null else "",
		"stash": stash.to_array(),
		"customer_served_day": served,
	}


## Applies data that SaveManager already validated.
func from_dict(data: Dictionary) -> void:
	reset_session()
	day = maxi(int(data["day"]), 1)
	gold = maxi(int(data["gold"]), 0)
	var weapon_id: StringName = StringName(str(data["equipped_weapon"]))
	equipped_weapon = ItemDB.get_item(weapon_id) as WeaponData if weapon_id != &"" else null
	stash.load_array(data["stash"] as Array)
	var served: Dictionary = data.get("customer_served_day", {}) as Dictionary
	for customer_id: Variant in served:
		customer_served_day[StringName(str(customer_id))] = int(served[customer_id])
	EventBus.day_changed.emit(day)
	EventBus.gold_changed.emit(gold)
	EventBus.weapon_equipped.emit(equipped_weapon)
