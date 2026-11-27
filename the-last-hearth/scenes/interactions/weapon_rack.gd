extends Node2D
## Rack holding a weapon. Interacting equips it. The rack reads GameState, so it stays empty
## once the player owns the weapon (after death, respawn or travel too).

@export var weapon: WeaponData

@onready var _weapon_sprite: Sprite2D = $WeaponSprite
@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	EventBus.weapon_equipped.connect(_on_weapon_equipped)
	_weapon_sprite.texture = weapon.icon if weapon != null else null
	_refresh()


func _on_interacted(_actor: Node2D) -> void:
	if weapon == null:
		push_warning("WeaponRack has no weapon assigned.")
		return
	GameState.equip_weapon(weapon)
	_refresh()


func _refresh() -> void:
	var taken: bool = weapon != null and GameState.owns_item_id(weapon.id)
	_weapon_sprite.visible = not taken
	_interactable.enabled = not taken and weapon != null


func _on_weapon_equipped(_weapon: WeaponData) -> void:
	_refresh()
