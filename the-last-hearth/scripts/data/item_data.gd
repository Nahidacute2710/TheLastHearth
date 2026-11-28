class_name ItemData
extends Resource
## Definition of an item. Instances live in data/items/ and are referenced by id.

@export var id: StringName = &""
@export var name_key: StringName = &""
@export var icon: Texture2D
@export var max_stack: int = 99
@export var sell_price: int = 0
## Eating it in the tavern gives this much extra max health for the next dungeon run (0 = not food).
@export var buff_max_health: int = 0
## Quest items survive death (kept in the bag).
@export var is_quest_item: bool = false
