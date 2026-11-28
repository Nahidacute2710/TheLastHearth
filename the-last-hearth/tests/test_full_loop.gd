extends "res://tests/test_case.gd"
## The whole MVP loop through real input where possible, checking data AND what the HUD shows:
## new game → pickaxe → mine → kill a miner → pick mushrooms → back → cook → eat → serve → save → reload.

const RACK_POS: Vector2 = Vector2(736, 386)
const HATCH_POS: Vector2 = Vector2(688, 418)
const LADDER_POS: Vector2 = Vector2(64, 44)
const STOVE_POS: Vector2 = Vector2(520, 110)
const TRAVELER_POS: Vector2 = Vector2(430, 340)
const MUSHROOM_PATH: String = "res://data/items/cave_mushroom.tres"
const STEW_PATH: String = "res://data/items/mushroom_stew.tres"


func _state() -> Node:
	return tree.root.get_node("GameState")


func _find(node_name: String) -> Node:
	return main.find_child(node_name, true, false)


func _walk_to(at: Vector2) -> void:
	player().global_position = at
	await wait_physics(5)


func _interact_at(at: Vector2) -> void:
	await _walk_to(at)
	await tap(&"interact")


func _mushroom_pickups() -> Array[Node2D]:
	var found: Array[Node2D] = []
	for child: Node in level().get_node("Entities").get_children():
		if child is Pickup and not child.is_queued_for_deletion():
			found.append(child as Node2D)
	return found


func test_full_mvp_loop() -> void:
	var mushroom: Resource = load(MUSHROOM_PATH)
	var stew: Resource = load(STEW_PATH)
	await boot_to_menu()
	(_find("NewGameButton") as Button).pressed.emit()
	await wait(0.4)
	var hud: Node = _find("HUD")
	var display: Node = _find("DayGoldDisplay")
	check_eq(display.call("get_day_text"), "Day 1", "start: day 1")

	# Take the pickaxe and go down.
	await _interact_at(RACK_POS)
	check(_state().get("equipped_weapon") != null, "pickaxe equipped")
	await _interact_at(HATCH_POS)
	await wait(0.8)
	check_eq(level().name, &"AbandonedMine", "in the mine")
	player().call("set_god_mode", true)

	# Kill the first miner (drop forced so the test is deterministic).
	var miner: Node2D = level().get_node("Entities/MinerR1_1") as Node2D
	var data: Resource = (miner.get("data") as Resource).duplicate(true)
	(data.get("loot") as Array)[0].set("chance", 1.0)
	miner.set("data", data)
	await _walk_to(miner.global_position + Vector2(-16, 0))
	# Lambdas capture locals by value, so the flag lives in an array.
	var killed: Array[bool] = [false]
	miner.get_node("Health").connect("died", func() -> void: killed[0] = true)
	for i: int in 15:
		if killed[0] or not is_instance_valid(miner):
			break
		player().call("attack_towards", miner.global_position - player().global_position)
		await wait(0.4)
	check(killed[0], "miner killed with the pickaxe")
	await wait(0.4)

	# Pick up the drop and three mushrooms that grow in the mine.
	var picked: int = 0
	for pickup: Node2D in _mushroom_pickups():
		if picked == 4:
			break
		await _walk_to(pickup.global_position)
		picked += 1
	check_eq(_state().get("bag").call("count_of", mushroom), 4, "4 mushrooms in the bag")
	check_eq(hud.call("get_item_count_text"), "×4", "HUD counts 4 mushrooms")

	# Back up the ladder: bag stored, new day.
	await _interact_at(LADDER_POS)
	await wait(0.8)
	check_eq(level().name, &"TavernMainHall", "back in the tavern")
	check_eq(_state().get("stash").call("count_of", mushroom), 4, "mushrooms stored in the stash")
	check(_find("Toast").call("get_messages").has("Stored 4 Cave Mushroom"), "stored toast")
	check_eq(hud.call("get_item_count_text"), "×0", "HUD bag count back to 0")
	check_eq(display.call("get_day_text"), "Day 2", "HUD day 2")

	# Cook two stews.
	await _interact_at(STOVE_POS)
	await wait(1.7)
	await tap(&"interact")
	await wait(1.7)
	check_eq(_state().get("stash").call("count_of", stew), 2, "2 stews cooked")
	check_eq(_state().get("stash").call("count_of", mushroom), 0, "4 mushrooms used")

	# Eat one through the inventory panel.
	await tap(&"inventory")
	var panel: Node = _find("InventoryPanel")
	panel.call("select_slot", &"stash", 0)
	panel.call("press_eat_button")
	await tap(&"inventory")
	check_eq(_state().get("max_health_buff"), 2, "buff +2")
	check_eq(hud.get("max_health"), 7, "HUD 7 pips")
	check_eq(hud.get("buff_pips"), 2, "HUD 2 buff pips")

	# Serve the traveler.
	await _interact_at(TRAVELER_POS)
	check_eq(_state().get("gold"), 30, "paid 30 gold")
	check_eq(display.call("get_gold_text"), "30 gold", "HUD gold")
	check_eq(_state().get("stash").call("count_of", stew), 0, "both stews used")

	# Save (main menu from the tavern), wipe memory like a fresh start, reload.
	var pause: Node = _find("PauseMenu")
	pause.call("open")
	(pause.find_child("MainMenuButton", true, false) as Button).pressed.emit()
	await tree.process_frame
	_state().call("start_new_game")
	check_eq(display.call("get_day_text"), "Day 1", "memory wiped before reload")
	(_find("ContinueButton") as Button).pressed.emit()
	await wait(0.4)
	check_eq(level().name, &"TavernMainHall", "reloaded into the tavern")
	check_eq(_state().get("day"), 2, "day after reload")
	check_eq(_state().get("gold"), 30, "gold after reload")
	check(_state().get("stash").call("is_empty"), "stash after reload (all used)")
	check_eq(_state().get("equipped_weapon"), load("res://data/items/rusty_pickaxe.tres"), "weapon after reload")
	check_eq(_state().get("max_health_buff"), 2, "buff after reload")
	check(_state().call("is_customer_served_today", &"weary_traveler"), "traveler already served today")
	check_eq(display.call("get_day_text"), "Day 2", "HUD day after reload")
	check_eq(display.call("get_gold_text"), "30 gold", "HUD gold after reload")
	check_eq(hud.get("max_health"), 7, "HUD 7 pips after reload")
	check_eq(hud.get("buff_pips"), 2, "HUD buff pips after reload")
	check_eq(hud.call("get_item_count_text"), "×0", "HUD bag count after reload")
	check(not level().find_child("WeaponRack", true, false).get_node("Interactable").get("enabled"), "rack empty after reload")
	check(not level().find_child("WearyTraveler", true, false).call("is_present"), "traveler gone until tomorrow")
