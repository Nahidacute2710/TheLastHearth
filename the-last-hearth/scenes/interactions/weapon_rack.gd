extends Node2D
## Rack holding a weapon. Interacting equips it once; the rack is empty afterwards.

@export var weapon: WeaponData

@onready var _weapon_sprite: Sprite2D = $WeaponSprite
@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	_weapon_sprite.texture = weapon.icon if weapon != null else null
	_refresh()


func _on_interacted(_actor: Node2D) -> void:
	if weapon == null:
		push_warning("WeaponRack has no weapon assigned.")
		return
	GameState.equip_weapon(weapon)
	_refresh()


func _refresh() -> void:
	var taken: bool = weapon != null and GameState.equipped_weapon == weapon
	_weapon_sprite.visible = not taken
	_interactable.enabled = not taken and weapon != null
