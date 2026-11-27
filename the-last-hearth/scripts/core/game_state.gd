extends Node
## Session data: day, gold, inventory, progress flags. Grows milestone by milestone.

var equipped_weapon: WeaponData = null


func equip_weapon(weapon: WeaponData) -> void:
	equipped_weapon = weapon
	EventBus.weapon_equipped.emit(weapon)


## Clears all session data (new game, tests).
func reset_session() -> void:
	equipped_weapon = null
