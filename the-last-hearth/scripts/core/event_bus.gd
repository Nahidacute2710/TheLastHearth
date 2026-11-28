extends Node
## Global signal hub. Declares signals only: no state, no logic.

## An Interactable started or stopped detecting the player body.
signal interactable_available(interactable: Interactable)
signal interactable_unavailable(interactable: Interactable)
## The interactable the player would use when pressing interact (null when none).
signal interaction_focus_changed(interactable: Interactable)

## SceneRouter finished swapping to a new level.
signal level_changed(level_id: StringName)

## GameState equipped a weapon (null when unequipped).
signal weapon_equipped(weapon: WeaponData)

## An enemy died (loot and quests listen to this).
signal enemy_died(enemy_data: EnemyData, position: Vector2)

## Player health changed (HUD).
signal player_health_changed(current: int, maximum: int)
## Player health reached 0.
signal player_died

## Items moved from the bag into the tavern stash (toast).
signal items_stored(item: ItemData, count: int)
## Gold or day changed (HUD).
signal gold_changed(gold: int)
signal day_changed(day: int)

## Show a short, already translated message (Toast).
signal toast_requested(message: String)

## Something worth saving happened in the tavern (SaveManager writes the save).
signal autosave_requested
