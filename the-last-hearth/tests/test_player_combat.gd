extends "res://tests/test_case.gd"

const HitboxScript: Script = preload("res://scripts/components/hitbox_component.gd")


## An enemy-style hitbox (mask 8 = PlayerHurtbox) sitting on the player.
func _enemy_hitbox(at: Vector2) -> Area2D:
	var hitbox: Area2D = HitboxScript.new() as Area2D
	hitbox.collision_layer = 0
	hitbox.collision_mask = 8
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	hitbox.add_child(shape)
	level().add_child(hitbox)
	hitbox.global_position = at
	return hitbox


func _health() -> Node:
	return player().call("get_health")


func test_hit_reduces_health_and_iframes_block_next_hit() -> void:
	await start_main()
	var body: CharacterBody2D = player()
	body.global_position = Vector2(384, 240)
	await wait_physics(2)
	var hud: Control = main.find_child("HUD", true, false) as Control
	check_eq(hud.get("current_health"), 5, "HUD shows full health at start")
	var hitbox: Area2D = _enemy_hitbox(body.global_position + Vector2(0, -8))
	hitbox.call("activate", 0.1)
	await wait(0.15)
	check_eq(_health().get("current_health"), 4, "hit removes 1 health")
	check_eq(hud.get("current_health"), 4, "HUD updates")
	hitbox.global_position = body.global_position + Vector2(0, -8)
	hitbox.call("activate", 0.1)
	await wait(0.15)
	check_eq(_health().get("current_health"), 4, "i-frames block the next hit")
	await wait(0.8)
	hitbox.global_position = body.global_position + Vector2(0, -8)
	hitbox.call("activate", 0.1)
	await wait(0.15)
	check_eq(_health().get("current_health"), 3, "hit lands after i-frames")


func test_dodge_moves_grants_iframes_and_has_cooldown() -> void:
	await start_main()
	var body: CharacterBody2D = player()
	body.global_position = Vector2(300, 240)
	await wait_physics(2)
	check(body.call("dodge", Vector2.RIGHT), "dodge starts")
	check(not body.call("dodge", Vector2.RIGHT), "cannot dodge again during cooldown")
	var hitbox: Area2D = _enemy_hitbox(body.global_position + Vector2(10, -8))
	hitbox.call("activate", 0.1)
	await wait(0.2)
	check_eq(_health().get("current_health"), 5, "no damage while dodging")
	check(body.global_position.x > 330.0, "dodge dashes in the given direction (x=%.1f)" % body.global_position.x)
	await wait(0.6)
	check(body.call("dodge", Vector2.LEFT), "dodge available after cooldown")


func test_god_mode_blocks_damage() -> void:
	await start_main()
	var body: CharacterBody2D = player()
	body.call("set_god_mode", true)
	var hitbox: Area2D = _enemy_hitbox(body.global_position + Vector2(0, -8))
	hitbox.call("activate", 0.1)
	await wait(0.15)
	check_eq(_health().get("current_health"), 5, "god mode takes no damage")


func test_death_returns_to_tavern_with_full_health_and_keeps_weapon() -> void:
	await start_main()
	tree.root.get_node("GameState").call("equip_weapon", load("res://data/items/rusty_pickaxe.tres"))
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	var old_player: CharacterBody2D = player()
	old_player.call("get_health").call("take_damage", 99)
	await tree.physics_frame
	check(old_player.call("is_dead"), "player is dead")
	check(not old_player.call("attack_towards", Vector2.RIGHT), "dead player cannot attack")
	await wait(1.4)
	check_eq(level().name, &"TavernMainHall", "wakes up in the tavern")
	check_eq(_health().get("current_health"), 5, "full health after waking up")
	check(tree.root.get_node("GameState").get("equipped_weapon") != null, "equipped weapon is kept")
	var hud: Control = main.find_child("HUD", true, false) as Control
	check_eq(hud.get("current_health"), 5, "HUD shows full health after waking up")


func test_miner_attack_hurts_player() -> void:
	await start_main()
	var body: CharacterBody2D = player()
	body.global_position = Vector2(384, 240)
	var miner: CharacterBody2D = (load("res://scenes/enemies/hollow_miner.tscn") as PackedScene).instantiate() as CharacterBody2D
	level().call("add_enemy", miner, body.global_position + Vector2(14, 0))
	await wait(0.4)
	check_eq(_health().get("current_health"), 5, "no damage during the wind-up")
	await wait(0.5)
	check_eq(_health().get("current_health"), 4, "the miner attack hurts the player")
