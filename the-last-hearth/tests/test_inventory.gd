extends "res://tests/test_case.gd"

const ItemDataScript: Script = preload("res://scripts/data/item_data.gd")
const InventoryScript: Script = preload("res://scripts/inventory/inventory.gd")


func _item(id: StringName, max_stack: int = 5, quest: bool = false) -> Resource:
	var item: Resource = ItemDataScript.new()
	item.set("id", id)
	item.set("name_key", &"ITEM_RUSTY_PICKAXE_NAME")
	item.set("max_stack", max_stack)
	item.set("is_quest_item", quest)
	return item


func test_add_stacks_and_respects_slots() -> void:
	var inventory: RefCounted = InventoryScript.new(2)
	var ore: Resource = _item(&"ore", 5)
	check_eq(inventory.call("add", ore, 7), 0, "7 items fit in 2 slots of 5")
	check_eq(inventory.call("used_slots"), 2, "two slots used")
	check_eq(inventory.call("add", ore, 5), 2, "only 3 more fit; 2 are returned")
	check_eq(inventory.call("count_of", ore), 10, "count is 10")


func test_remove_is_all_or_nothing() -> void:
	var inventory: RefCounted = InventoryScript.new(4)
	var ore: Resource = _item(&"ore", 5)
	inventory.call("add", ore, 6)
	check(not inventory.call("remove", ore, 7), "cannot remove more than owned")
	check_eq(inventory.call("count_of", ore), 6, "failed remove changes nothing")
	check(inventory.call("remove", ore, 6), "remove all")
	check(inventory.call("is_empty"), "empty after removing everything")


func test_death_empties_bag_except_quest_items_and_keeps_stash_and_weapon() -> void:
	var state: Node = tree.root.get_node("GameState")
	var ore: Resource = _item(&"ore")
	var letter: Resource = _item(&"letter", 1, true)
	state.call("equip_weapon", load("res://data/items/rusty_pickaxe.tres"))
	state.get("bag").call("add", ore, 3)
	state.get("bag").call("add", letter, 1)
	state.get("stash").call("add", ore, 2)
	tree.root.get_node("EventBus").emit_signal("player_died")
	check_eq(state.get("bag").call("count_of", ore), 0, "bag resources are lost")
	check_eq(state.get("bag").call("count_of", letter), 1, "quest item is kept")
	check_eq(state.get("stash").call("count_of", ore), 2, "stash is untouched")
	check(state.get("equipped_weapon") != null, "equipped weapon is kept")


func test_safe_return_stores_bag_advances_day_and_shows_toast() -> void:
	await start_main()
	var state: Node = tree.root.get_node("GameState")
	var ore: Resource = _item(&"ore", 99)
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	check_eq(state.get("day"), 1, "going down does not change the day")
	state.get("bag").call("add", ore, 3)
	router().call("go_to", &"tavern", &"cellar_door")
	await wait(0.4)
	check(state.get("bag").call("is_empty"), "bag is emptied")
	check_eq(state.get("stash").call("count_of", ore), 3, "items moved to the stash")
	check_eq(state.get("day"), 2, "returning to the tavern starts a new day")
	var toast: Node = main.find_child("Toast", true, false)
	var messages: PackedStringArray = toast.call("get_messages")
	check(messages.size() == 1 and messages[0] == "Stored 3 Pickaxe", "toast shows the stored items (%s)" % str(messages))


func test_death_return_advances_day_and_stores_nothing() -> void:
	await start_main()
	var state: Node = tree.root.get_node("GameState")
	var ore: Resource = _item(&"ore", 99)
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	state.get("bag").call("add", ore, 3)
	player().call("get_health").call("take_damage", 99)
	await wait(1.4)
	check_eq(level().name, &"TavernMainHall", "back in the tavern")
	check_eq(state.get("day"), 2, "death also starts a new day")
	check_eq(state.get("stash").call("count_of", ore), 0, "nothing from the lost bag reaches the stash")
	check(state.get("bag").call("is_empty"), "bag is empty")


func test_weapon_rack_stays_empty_after_travel_and_death() -> void:
	await start_main()
	player().global_position = Vector2(736, 386)
	await wait_physics(5)
	await tap(&"interact")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	router().call("go_to", &"tavern", &"cellar_door")
	await wait(0.8)
	var rack: Node = level().find_child("WeaponRack", true, false)
	check(not rack.get_node("Interactable").get("enabled"), "rack empty after a round trip")
	check(not rack.get_node("WeaponSprite").get("visible"), "no pickaxe sprite after a round trip")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	player().call("get_health").call("take_damage", 99)
	await wait(1.4)
	rack = level().find_child("WeaponRack", true, false)
	check(not rack.get_node("Interactable").get("enabled"), "rack empty after death and respawn")
	check(not rack.get_node("WeaponSprite").get("visible"), "no pickaxe sprite after death")
