class_name Inventory
extends RefCounted
## Slot-limited item container (bag, stash). Each slot holds one ItemStack up to item.max_stack.
## Pure data: UI listens to `changed`.

signal changed

var slot_count: int

var _stacks: Array[ItemStack] = []


func _init(slots: int = 12) -> void:
	slot_count = slots


## Adds items. Returns how many could NOT be added because the inventory is full.
func add(item: ItemData, amount: int) -> int:
	var left: int = amount
	for stack: ItemStack in _stacks:
		if left <= 0:
			break
		if stack.item == item and stack.space_left() > 0:
			var moved: int = mini(left, stack.space_left())
			stack.count += moved
			left -= moved
	while left > 0 and _stacks.size() < slot_count:
		var moved: int = mini(left, item.max_stack)
		_stacks.append(ItemStack.new(item, moved))
		left -= moved
	if left != amount:
		changed.emit()
	return left


## Removes exactly `amount` items, or nothing when there are not enough. Returns true on success.
func remove(item: ItemData, amount: int) -> bool:
	if amount <= 0 or count_of(item) < amount:
		return false
	var left: int = amount
	for i: int in range(_stacks.size() - 1, -1, -1):
		var stack: ItemStack = _stacks[i]
		if stack.item != item:
			continue
		var taken: int = mini(left, stack.count)
		stack.count -= taken
		left -= taken
		if stack.count == 0:
			_stacks.remove_at(i)
		if left == 0:
			break
	changed.emit()
	return true


func count_of(item: ItemData) -> int:
	var total: int = 0
	for stack: ItemStack in _stacks:
		if stack.item == item:
			total += stack.count
	return total


func has_item_id(id: StringName) -> bool:
	for stack: ItemStack in _stacks:
		if stack.item.id == id:
			return true
	return false


## Copy of the slots (changing it does not change the inventory).
func get_stacks() -> Array[ItemStack]:
	var copy: Array[ItemStack] = []
	for stack: ItemStack in _stacks:
		copy.append(ItemStack.new(stack.item, stack.count))
	return copy


## Item totals merged across slots, in first-seen order.
func get_totals() -> Dictionary[ItemData, int]:
	var totals: Dictionary[ItemData, int] = {}
	for stack: ItemStack in _stacks:
		totals[stack.item] = totals.get(stack.item, 0) + stack.count
	return totals


func is_empty() -> bool:
	return _stacks.is_empty()


func used_slots() -> int:
	return _stacks.size()


func clear() -> void:
	if _stacks.is_empty():
		return
	_stacks.clear()
	changed.emit()


## Removes everything except quest items.
func clear_except_quest_items() -> void:
	var kept: Array[ItemStack] = []
	for stack: ItemStack in _stacks:
		if stack.item.is_quest_item:
			kept.append(stack)
	if kept.size() == _stacks.size():
		return
	_stacks = kept
	changed.emit()
