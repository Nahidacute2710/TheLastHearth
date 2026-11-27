class_name CustomerData
extends Resource
## A tavern customer type. Instances in data/customers/.

@export var id: StringName = &""
@export var name_key: StringName = &""
@export var sprite: Texture2D
## Dish the customer orders.
@export var wanted_item: ItemData
## Gold paid when served.
@export var payment: int = 15
