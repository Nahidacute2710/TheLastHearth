class_name ItemData
extends Resource
## Definition of an item. Instances live in data/items/ and are referenced by id.

@export var id: StringName = &""
@export var name_key: StringName = &""
@export var icon: Texture2D
@export var max_stack: int = 99
@export var sell_price: int = 0
