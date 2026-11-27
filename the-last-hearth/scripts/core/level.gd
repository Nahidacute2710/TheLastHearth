class_name Level
extends Node2D
## Base script for a playable room scene. Expected children (unique names):
## %Floor (TileMapLayer), %Player (Player), %Entities (y-sorted Node2D), %Spawns (Node2D with Marker2D children).
## The level owns its player instance and passes the room bounds down to the player camera.

const DEFAULT_SPAWN: StringName = &"default"
const PICKUP_SCENE: PackedScene = preload("res://scenes/items/pickup.tscn")
## Random offset of dropped loot around the enemy (px).
const LOOT_SCATTER: float = 6.0

@onready var _floor: TileMapLayer = %Floor
@onready var _player: Player = %Player
@onready var _spawns: Node2D = %Spawns
@onready var _entities: Node2D = %Entities

var _hit_stop_active: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_player.set_camera_limits(_get_room_rect_px())
	_player.attack_landed.connect(_on_player_attack_landed)
	_player.died.connect(_on_player_died)
	EventBus.enemy_died.connect(_on_enemy_died)
	for child: Node in _entities.get_children():
		if child.has_method(&"set_target"):
			child.call(&"set_target", _player)


## Called by SceneRouter right after the level enters the tree.
func place_player(spawn_id: StringName) -> void:
	var id: StringName = spawn_id if spawn_id != &"" else DEFAULT_SPAWN
	var marker: Marker2D = _spawns.get_node_or_null(NodePath(id)) as Marker2D
	if marker == null:
		push_warning("Level %s has no spawn '%s', using '%s'." % [name, id, DEFAULT_SPAWN])
		marker = _spawns.get_node_or_null(NodePath(DEFAULT_SPAWN)) as Marker2D
	if marker == null:
		push_error("Level %s has no default spawn." % name)
		return
	_player.global_position = marker.global_position
	_player.velocity = Vector2.ZERO


## get_used_rect() is in tile coordinates; convert to pixels before using it for the camera.
func _get_room_rect_px() -> Rect2i:
	var used_tiles: Rect2i = _floor.get_used_rect()
	var tile_size: Vector2i = _floor.tile_set.tile_size
	var layer_origin: Vector2i = Vector2i(_floor.position)
	return Rect2i(layer_origin + used_tiles.position * tile_size, used_tiles.size * tile_size)


## Freezes every entity (player and enemies) for a short time. UI and fade keep running.
func hit_stop(duration: float) -> void:
	if duration <= 0.0 or _hit_stop_active:
		return
	_hit_stop_active = true
	_entities.set_deferred(&"process_mode", Node.PROCESS_MODE_DISABLED)
	await get_tree().create_timer(duration, true, false, true).timeout
	_entities.process_mode = Node.PROCESS_MODE_INHERIT
	_hit_stop_active = false


func is_hit_stop_active() -> bool:
	return _hit_stop_active


func get_player() -> Player:
	return _player


## Adds an enemy (or any entity with set_target) to the room, targeting the player.
func add_enemy(enemy: Node2D, at: Vector2) -> void:
	_entities.add_child(enemy)
	enemy.global_position = at
	if enemy.has_method(&"set_target"):
		enemy.call(&"set_target", _player)


func _on_player_attack_landed(_hurtbox: HurtboxComponent) -> void:
	var weapon: WeaponData = GameState.equipped_weapon
	if weapon != null:
		hit_stop(weapon.hit_stop_time)


## Death: short pause, then wake up in the tavern with full health (new player instance).
func _on_player_died() -> void:
	await get_tree().create_timer(_player.data.death_delay, false).timeout
	SceneRouter.go_to(SceneRouter.TAVERN, DEFAULT_SPAWN)


## Drops one pickup on the floor (used for enemy loot).
func spawn_pickup(item: ItemData, count: int, at: Vector2) -> Pickup:
	var pickup: Pickup = PICKUP_SCENE.instantiate() as Pickup
	pickup.item = item
	pickup.count = count
	pickup.position = at
	_entities.add_child.call_deferred(pickup)
	return pickup


func _on_enemy_died(enemy_data: EnemyData, at: Vector2) -> void:
	for entry: LootEntry in enemy_data.loot:
		var amount: int = entry.roll(_rng)
		if amount > 0:
			var offset: Vector2 = Vector2(_rng.randf_range(-LOOT_SCATTER, LOOT_SCATTER), _rng.randf_range(-LOOT_SCATTER, LOOT_SCATTER))
			spawn_pickup(entry.item, amount, _entities.to_local(at) + offset)
