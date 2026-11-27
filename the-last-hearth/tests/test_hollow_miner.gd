extends "res://tests/test_case.gd"

const MINER_SCENE: String = "res://scenes/enemies/hollow_miner.tscn"
const HurtboxScript: Script = preload("res://scripts/components/hurtbox_component.gd")
const HealthComponentScript: Script = preload("res://scripts/components/health_component.gd")

var _target_health: Node = null


## Tavern has no enemies; spawn one miner and a dummy target with a player hurtbox (layer 4).
func _setup(target_offset: Vector2) -> CharacterBody2D:
	await start_main()
	player().global_position = Vector2(100, 100)
	var target: Node2D = Node2D.new()
	_target_health = HealthComponentScript.new()
	_target_health.set("max_health", 10)
	target.add_child(_target_health)
	var hurtbox: Area2D = HurtboxScript.new() as Area2D
	hurtbox.collision_layer = 8
	hurtbox.collision_mask = 0
	hurtbox.monitoring = false
	hurtbox.set("health", _target_health)
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(10, 18)
	shape.shape = rect
	shape.position = Vector2(0, -9)
	hurtbox.add_child(shape)
	target.add_child(hurtbox)
	level().get_node("%Entities").add_child(target)
	target.global_position = Vector2(400, 260)
	var miner: CharacterBody2D = (load(MINER_SCENE) as PackedScene).instantiate() as CharacterBody2D
	level().call("add_enemy", miner, target.global_position + target_offset)
	miner.call("set_target", target)
	return miner


func test_idle_when_far_and_chases_when_near() -> void:
	var miner: CharacterBody2D = await _setup(Vector2(250, 0))
	await wait(0.3)
	check_eq(miner.get("state"), 0, "idle when target is far")
	miner.global_position = Vector2(400 + 90, 260)
	var start_x: float = miner.global_position.x
	await wait(0.5)
	check_eq(miner.get("state"), 1, "chases when target is within detection radius")
	check(miner.global_position.x < start_x - 10.0, "moves toward the target")


func test_contact_does_not_hurt_only_the_windup_attack_does() -> void:
	var miner: CharacterBody2D = await _setup(Vector2(12, 0))
	await wait(0.3)
	check_eq(miner.get("state"), 2, "winding up while touching the target")
	check_eq(_target_health.get("current_health"), 10, "no damage from contact or wind-up")
	await wait(0.6)
	check_eq(_target_health.get("current_health"), 9, "the attack after the wind-up deals 1 damage")


func test_hit_cancels_windup() -> void:
	var miner: CharacterBody2D = await _setup(Vector2(12, 0))
	await wait(0.3)
	miner.get_node("%Hurtbox").call("receive_hit", 1, Vector2(100, 0), null)
	await tree.physics_frame
	check_eq(miner.get("state"), 5, "being hit switches to HURT")
	await wait(0.5)
	check_eq(_target_health.get("current_health"), 10, "cancelled wind-up deals no damage")


func test_killed_miner_emits_and_is_removed() -> void:
	var miner: CharacterBody2D = await _setup(Vector2(250, 0))
	var died: Array[StringName] = []
	var on_died: Callable = func(enemy_data: Resource, _pos: Vector2) -> void: died.append(enemy_data.get("id"))
	tree.root.get_node("EventBus").connect("enemy_died", on_died)
	var hurtbox: Node = miner.get_node("%Hurtbox")
	for i: int in 3:
		hurtbox.call("receive_hit", 1, Vector2.ZERO, null)
	await wait(0.5)
	tree.root.get_node("EventBus").disconnect("enemy_died", on_died)
	check_eq(died, [&"hollow_miner"] as Array[StringName], "enemy_died emitted once with the data id")
	check(not is_instance_valid(miner), "dead miner is freed")


func test_mine_has_miners_targeting_the_player() -> void:
	await start_main()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	var miners: Array[Node] = tree.get_nodes_in_group(&"enemies")
	check_eq(miners.size(), 10, "10 miners in the mine")
	var all_target_player: bool = true
	for miner: Node in miners:
		all_target_player = all_target_player and miner.get("target") == player()
	check(all_target_player, "every miner targets the player")
