extends Node
## Session data: day, gold, bag, tavern stash, equipped gear.
## Bag = items picked up during a dungeon run. Stash = tavern storage (cooking reads from it).
## Rules (DECISION_LOG, CP-C): safe return moves the bag into the stash; death empties the bag
## except quest items; every return from the dungeon to the tavern starts a new day.

const BAG_SLOTS: int = 12
const STASH_SLOTS: int = 30
const HEARTH_TABLE: HearthTable = preload("res://data/hearth/hearth_levels.tres")

## Why the Hearth Flame cannot be kindled (see get_kindle_block()).
const KINDLE_OK: StringName = &""
const KINDLE_MAX_LEVEL: StringName = &"max_level"
const KINDLE_NEED_GOLD: StringName = &"need_gold"
const KINDLE_NEED_EMBER: StringName = &"need_ember"

var equipped_weapon: WeaponData = null
var bag: Inventory = Inventory.new(BAG_SLOTS)
var stash: Inventory = Inventory.new(STASH_SLOTS)
var day: int = 1
var gold: int = 0
## Extra max health from food eaten in the tavern, for the next dungeon run (0 = none).
## Cleared when the player comes back to the tavern (safe or dead). One meal per run.
var max_health_buff: int = 0
## Customer id -> last day it was served.
var customer_served_day: Dictionary[StringName, int] = {}
## Hearth Flame level, 1 (start) to HEARTH_TABLE.max_level().
var hearth_level: int = 1
## Letter parts revealed so far (translation keys), in the order they were revealed.
var hearth_letters: Array[StringName] = []

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


## True when `item` can be eaten now: it is food, it is in the stash, the player is in the tavern
## and has not eaten this run yet.
func can_eat(item: ItemData) -> bool:
	return item != null and item.buff_max_health > 0 and max_health_buff == 0 \
		and SceneRouter.current_level_id == SceneRouter.TAVERN and stash.count_of(item) > 0


## Eats one `item` from the stash. Returns false (and changes nothing) when can_eat() is false.
func eat_from_stash(item: ItemData) -> bool:
	if not can_eat(item) or not stash.remove(item, 1):
		return false
	_set_max_health_buff(item.buff_max_health)
	EventBus.autosave_requested.emit()
	return true


func _set_max_health_buff(amount: int) -> void:
	if max_health_buff == amount:
		return
	max_health_buff = amount
	EventBus.max_health_buff_changed.emit(max_health_buff)


func get_hearth_table() -> HearthTable:
	return HEARTH_TABLE


## Data of the next level, or null at the maximum level.
func get_next_hearth_level() -> HearthLevelData:
	return HEARTH_TABLE.get_level(hearth_level + 1)


func is_hearth_max_level() -> bool:
	return hearth_level >= HEARTH_TABLE.max_level()


## KINDLE_OK when the next level can be paid now, else the first reason it cannot
## (max level, then gold, then Ember Coal in the stash).
func get_kindle_block() -> StringName:
	var next: HearthLevelData = get_next_hearth_level()
	if next == null:
		return KINDLE_MAX_LEVEL
	if gold < next.gold_cost:
		return KINDLE_NEED_GOLD
	if stash.count_of(HEARTH_TABLE.cost_item) < next.ember_cost:
		return KINDLE_NEED_EMBER
	return KINDLE_OK


## Pays the next level (gold + Ember Coal from the stash) and raises the Hearth Flame.
## `free` skips the cost (debug key). Returns false and changes nothing when it cannot.
func kindle_hearth(free: bool = false) -> bool:
	var next: HearthLevelData = get_next_hearth_level()
	if next == null or (not free and get_kindle_block() != KINDLE_OK):
		return false
	if not free:
		stash.remove(HEARTH_TABLE.cost_item, next.ember_cost)
		add_gold(-next.gold_cost)
	hearth_level = next.level
	if next.letter_key != &"" and not hearth_letters.has(next.letter_key):
		hearth_letters.append(next.letter_key)
	EventBus.hearth_level_changed.emit(hearth_level)
	EventBus.hearth_kindled.emit(hearth_level)
	EventBus.autosave_requested.emit()
	return true


func get_cook_batch_size() -> int:
	return HEARTH_TABLE.cook_batch_size(hearth_level)


func get_cook_time_factor() -> float:
	return HEARTH_TABLE.cook_time_factor(hearth_level)


func get_customer_slots() -> int:
	return HEARTH_TABLE.customer_slots(hearth_level)


func get_hearth_max_health_bonus() -> int:
	return HEARTH_TABLE.max_health_bonus(hearth_level)


func get_dodge_distance_factor() -> float:
	return HEARTH_TABLE.dodge_distance_factor(hearth_level)


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


## The ONLY way to start a new game: resets every part of the session (day, gold, bag, stash,
## equipped weapon, served customers, level tracking) and notifies every listener (HUD, weapon rack...).
## Settings such as the locale are not session data and are kept.
## In-progress cooking lives in the tavern level, which is unloaded before a new game starts.
func start_new_game() -> void:
	_clear_session()
	_notify_session_changed()


## Wipes session fields without notifying. Used by start_new_game() and from_dict().
## Any new session field must be cleared here (a test checks the common ones).
func _clear_session() -> void:
	equipped_weapon = null
	bag.clear()
	stash.clear()
	day = 1
	gold = 0
	customer_served_day.clear()
	max_health_buff = 0
	hearth_level = 1
	hearth_letters.clear()
	_last_level_id = &""


## Pushes the whole state to listeners after a reset or a load (bag/stash emit their own `changed`).
func _notify_session_changed() -> void:
	EventBus.day_changed.emit(day)
	EventBus.gold_changed.emit(gold)
	EventBus.weapon_equipped.emit(equipped_weapon)
	EventBus.max_health_buff_changed.emit(max_health_buff)
	EventBus.hearth_level_changed.emit(hearth_level)


func _on_level_changed(level_id: StringName) -> void:
	var from_dungeon: bool = _last_level_id == SceneRouter.DUNGEON
	_last_level_id = level_id
	if from_dungeon and level_id == SceneRouter.TAVERN:
		_report_stored(_store_and_count())
		_set_max_health_buff(0)
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
	_set_max_health_buff(0)


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
		"max_health_buff": max_health_buff,
		"hearth_level": hearth_level,
		"hearth_letters": hearth_letters.map(func(key: StringName) -> String: return String(key)),
	}


## Applies data that SaveManager already validated. Replaces the whole session: nothing from the
## game that was running is kept.
func from_dict(data: Dictionary) -> void:
	_clear_session()
	day = maxi(int(data["day"]), 1)
	gold = maxi(int(data["gold"]), 0)
	var weapon_id: StringName = StringName(str(data["equipped_weapon"]))
	equipped_weapon = ItemDB.get_item(weapon_id) as WeaponData if weapon_id != &"" else null
	stash.load_array(data["stash"] as Array)
	var served: Dictionary = data.get("customer_served_day", {}) as Dictionary
	for customer_id: Variant in served:
		customer_served_day[StringName(str(customer_id))] = int(served[customer_id])
	max_health_buff = maxi(int(data.get("max_health_buff", 0)), 0)
	# Saves from before VS-E1 have no hearth fields: level 1, no letters.
	hearth_level = clampi(int(data.get("hearth_level", 1)), 1, HEARTH_TABLE.max_level())
	for key: Variant in data.get("hearth_letters", []) as Array:
		var letter: StringName = StringName(str(key))
		if not hearth_letters.has(letter):
			hearth_letters.append(letter)
	# Every level reached reveals its letter part, even if the saved list missed it.
	for letter: StringName in HEARTH_TABLE.letters_up_to(hearth_level):
		if not hearth_letters.has(letter):
			hearth_letters.append(letter)
	_notify_session_changed()
