extends "res://tests/test_case.gd"

const HealthComponentScript: Script = preload("res://scripts/components/health_component.gd")
const HurtboxScript: Script = preload("res://scripts/components/hurtbox_component.gd")
const HitboxScript: Script = preload("res://scripts/components/hitbox_component.gd")

var _arena: Node2D = null


func after_each() -> void:
	if _arena != null:
		_arena.queue_free()
		_arena = null
	await super.after_each()


func test_health_damage_heal_and_death() -> void:
	var health: Node = HealthComponentScript.new()
	health.set("max_health", 3)
	tree.root.add_child(health)
	var deaths: Array[int] = [0]
	health.connect("died", func() -> void: deaths[0] += 1)
	health.call("take_damage", 1)
	check_eq(health.get("current_health"), 2, "damage reduces health")
	health.call("heal", 5)
	check_eq(health.get("current_health"), 3, "heal is capped at max")
	health.call("take_damage", 10)
	check_eq(health.get("current_health"), 0, "health never below 0")
	health.call("take_damage", 1)
	check_eq(deaths[0], 1, "died emitted exactly once")
	health.call("reset")
	check_eq(health.get("current_health"), 3, "reset restores full health")
	health.queue_free()


func test_hitbox_hits_each_hurtbox_once_per_activation() -> void:
	var parts: Array[Node] = _build_arena()
	var hitbox: Area2D = parts[0] as Area2D
	var health: Node = parts[2]
	hitbox.call("activate", 0.1)
	await wait_physics(6)
	check_eq(health.get("current_health"), 4, "one hit per activation")
	await wait(0.15)
	hitbox.call("activate", 0.1)
	await wait_physics(6)
	check_eq(health.get("current_health"), 3, "new activation hits again")


func test_invulnerability_blocks_hits() -> void:
	var parts: Array[Node] = _build_arena()
	var hitbox: Area2D = parts[0] as Area2D
	var hurtbox: Area2D = parts[1] as Area2D
	var health: Node = parts[2]
	hurtbox.call("start_invulnerability", 0.3)
	await wait_physics(2)
	hitbox.call("activate", 0.1)
	await wait_physics(6)
	check_eq(health.get("current_health"), 5, "i-frames block damage")
	check(not hurtbox.call("receive_hit", 1, Vector2.ZERO, null), "receive_hit refused while invulnerable")
	await wait(0.35)
	hitbox.call("activate", 0.1)
	await wait_physics(6)
	check_eq(health.get("current_health"), 4, "hit lands after i-frames end")


## Hitbox (mask 5) overlapping an enemy hurtbox (layer 5) with 5 HP.
func _build_arena() -> Array[Node]:
	_arena = Node2D.new()
	tree.root.add_child(_arena)
	var health: Node = HealthComponentScript.new()
	health.set("max_health", 5)
	_arena.add_child(health)
	var hurtbox: Area2D = HurtboxScript.new() as Area2D
	hurtbox.collision_layer = 16
	hurtbox.collision_mask = 0
	hurtbox.monitoring = false
	hurtbox.set("health", health)
	hurtbox.add_child(_circle(8.0))
	_arena.add_child(hurtbox)
	var hitbox: Area2D = HitboxScript.new() as Area2D
	hitbox.collision_layer = 0
	hitbox.collision_mask = 16
	hitbox.add_child(_circle(8.0))
	_arena.add_child(hitbox)
	hitbox.position = Vector2(4, 0)
	return [hitbox, hurtbox, health]


func _circle(radius: float) -> CollisionShape2D:
	var shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	return shape
