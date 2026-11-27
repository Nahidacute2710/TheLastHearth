extends "res://tests/test_case.gd"

const HurtboxScript: Script = preload("res://scripts/components/hurtbox_component.gd")
const HealthComponentScript: Script = preload("res://scripts/components/health_component.gd")
const RACK_POS: Vector2 = Vector2(736, 386)


func _game_state() -> Node:
	return tree.root.get_node("GameState")


func test_cannot_attack_without_weapon() -> void:
	await start_main()
	check(not player().call("attack_towards", Vector2.RIGHT), "no swing without a weapon")


func test_rack_equips_pickaxe_once() -> void:
	await start_main()
	player().global_position = RACK_POS
	await wait_physics(5)
	await tap(&"interact")
	var weapon: Resource = _game_state().get("equipped_weapon")
	check(weapon != null and weapon.get("id") == &"rusty_pickaxe", "rack equips the rusty pickaxe")
	var rack_area: Area2D = level().find_child("WeaponRack", true, false).get_node("Interactable") as Area2D
	check(not rack_area.get("enabled"), "rack is empty after taking the pickaxe")


func test_swing_hits_in_aim_direction_only_and_respects_cooldown() -> void:
	await start_main()
	_game_state().call("equip_weapon", load("res://data/items/rusty_pickaxe.tres"))
	var body: CharacterBody2D = player()
	body.global_position = Vector2(384, 200)
	await wait_physics(2)
	var front: Node = _dummy(body.global_position + Vector2(20, -8))
	var back: Node = _dummy(body.global_position + Vector2(-20, -8))
	await wait_physics(2)
	check(body.call("attack_towards", Vector2.RIGHT), "swing starts")
	await wait(0.15)
	check_eq(front.get("current_health"), 4, "target in front is hit once")
	check_eq(back.get("current_health"), 5, "target behind is not hit")
	check(not body.call("attack_towards", Vector2.RIGHT), "cooldown blocks an immediate second swing")
	await wait(0.4)
	check(body.call("attack_towards", Vector2.LEFT), "swing again after cooldown")
	await wait(0.15)
	check_eq(back.get("current_health"), 4, "aiming left hits the target behind")


func test_landing_a_hit_triggers_hit_stop() -> void:
	await start_main()
	_game_state().call("equip_weapon", load("res://data/items/rusty_pickaxe.tres"))
	var body: CharacterBody2D = player()
	body.global_position = Vector2(384, 200)
	await wait_physics(2)
	_dummy(body.global_position + Vector2(20, -8))
	await wait_physics(2)
	body.call("attack_towards", Vector2.RIGHT)
	var saw_stop: bool = false
	for i: int in 10:
		await tree.physics_frame
		if level().call("is_hit_stop_active"):
			saw_stop = true
	check(saw_stop, "hit-stop starts when the swing lands")
	await wait(0.15)
	check(not level().call("is_hit_stop_active"), "hit-stop ends")
	check_eq(level().get_node("%Entities").process_mode, Node.PROCESS_MODE_INHERIT, "entities resume")


func _dummy(at: Vector2) -> Node:
	var health: Node = HealthComponentScript.new()
	health.set("max_health", 5)
	var hurtbox: Area2D = HurtboxScript.new() as Area2D
	hurtbox.collision_layer = 16
	hurtbox.collision_mask = 0
	hurtbox.monitoring = false
	hurtbox.set("health", health)
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	hurtbox.add_child(shape)
	hurtbox.add_child(health)
	level().add_child(hurtbox)
	hurtbox.global_position = at
	return health
