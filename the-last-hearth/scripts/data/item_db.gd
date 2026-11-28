class_name ItemDB
extends RefCounted
## Item id -> resource path. Saves store ids only; this turns them back into ItemData.
## Every file in data/items/ must be listed here (a test checks it).

const ITEM_PATHS: Dictionary[StringName, String] = {
	&"rusty_pickaxe": "res://data/items/rusty_pickaxe.tres",
	&"cave_mushroom": "res://data/items/cave_mushroom.tres",
	&"mushroom_stew": "res://data/items/mushroom_stew.tres",
}


static func get_item(id: StringName) -> ItemData:
	if not ITEM_PATHS.has(id):
		return null
	return load(ITEM_PATHS[id]) as ItemData


static func has_item(id: StringName) -> bool:
	return ITEM_PATHS.has(id)
