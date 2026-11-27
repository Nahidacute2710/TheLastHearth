class_name ItemStack
extends RefCounted
## One inventory slot: an item and how many of it (1..item.max_stack).

var item: ItemData
var count: int


func _init(stack_item: ItemData = null, stack_count: int = 0) -> void:
	item = stack_item
	count = stack_count


func space_left() -> int:
	return item.max_stack - count
