extends Control
## Bag + tavern stash panel. The `inventory` action (Tab, I) opens and closes it; `pause` (Esc) closes it.
## The world is paused while it is open. Input is read in _input and marked handled, so Tab never
## reaches GUI focus navigation (TECH-006). No control in the panel can take focus.
## Hovering or clicking a slot shows the item name below the grids. Selecting food in the stash
## (in the tavern) shows an Eat button.

const SLOT_SIZE: Vector2 = Vector2(20.0, 20.0)
const SLOT_COLOR: Color = Color(0.16, 0.13, 0.15)
const SLOT_BORDER: Color = Color(0.0862745, 0.0784314, 0.109804)

@export var label_settings: LabelSettings

@onready var _bag_grid: GridContainer = %BagGrid
@onready var _stash_grid: GridContainer = %StashGrid
@onready var _item_name: Label = %ItemName
@onready var _eat_button: Button = %EatButton

var _selected_slot: Control = null
var _slot_items: Dictionary[Control, ItemData] = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	GameState.bag.changed.connect(_refresh)
	GameState.stash.changed.connect(_refresh)
	_eat_button.focus_mode = Control.FOCUS_NONE
	_eat_button.pressed.connect(_on_eat_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"inventory") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if visible:
			close()
		elif SceneRouter.get_current_level() != null and not SceneRouter.is_transitioning() and not get_tree().paused:
			open()
	elif visible and event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		close()


func open() -> void:
	_selected_slot = null
	_refresh()
	show()
	get_tree().paused = true


func close() -> void:
	hide()
	get_tree().paused = false


func is_open() -> bool:
	return visible


## Count text of each used slot, for tests. which = &"bag" or &"stash".
func get_slot_texts(which: StringName) -> PackedStringArray:
	var grid: GridContainer = _bag_grid if which == &"bag" else _stash_grid
	var texts: PackedStringArray = []
	for slot: Node in grid.get_children():
		var label: Label = slot.get_node("Count") as Label
		if label.text != "":
			texts.append(label.text)
	return texts


func _refresh() -> void:
	_fill(_bag_grid, GameState.bag)
	_fill(_stash_grid, GameState.stash)
	_show_item(_selected_item())
	_update_eat_button()


func _fill(grid: GridContainer, inventory: Inventory) -> void:
	while grid.get_child_count() < inventory.slot_count:
		grid.add_child(_make_slot())
	var stacks: Array[ItemStack] = inventory.get_stacks()
	for i: int in grid.get_child_count():
		var slot: Control = grid.get_child(i) as Control
		var icon: TextureRect = slot.get_node("Icon") as TextureRect
		var count: Label = slot.get_node("Count") as Label
		if i < stacks.size():
			icon.texture = stacks[i].item.icon
			count.text = str(stacks[i].count) if stacks[i].count > 1 or stacks[i].item.max_stack > 1 else ""
			_slot_items[slot] = stacks[i].item
		else:
			icon.texture = null
			count.text = ""
			_slot_items[slot] = null


func _make_slot() -> Control:
	var slot: Panel = Panel.new()
	slot.custom_minimum_size = SLOT_SIZE
	slot.focus_mode = Control.FOCUS_NONE
	slot.mouse_entered.connect(_on_slot_hovered.bind(slot))
	slot.mouse_exited.connect(_on_slot_unhovered)
	slot.gui_input.connect(_on_slot_gui_input.bind(slot))
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = SLOT_COLOR
	style.border_color = SLOT_BORDER
	style.set_border_width_all(1)
	slot.add_theme_stylebox_override(&"panel", style)
	var icon: TextureRect = TextureRect.new()
	icon.name = "Icon"
	icon.position = Vector2(2.0, 2.0)
	icon.size = Vector2(16.0, 16.0)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(icon)
	var count: Label = Label.new()
	count.name = "Count"
	count.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	count.label_settings = label_settings
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.position = Vector2(0.0, 8.0)
	count.size = Vector2(19.0, 12.0)
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(count)
	return slot


func get_item_name_text() -> String:
	return _item_name.text


## Shows the item name of a slot (index in the grid). which = &"bag" or &"stash". Used by tests.
func hover_slot(which: StringName, index: int) -> void:
	var grid: GridContainer = _bag_grid if which == &"bag" else _stash_grid
	_on_slot_hovered(grid.get_child(index) as Control)


func select_slot(which: StringName, index: int) -> void:
	var grid: GridContainer = _bag_grid if which == &"bag" else _stash_grid
	_select(grid.get_child(index) as Control)


func is_eat_button_visible() -> bool:
	return _eat_button.visible


func is_eat_button_enabled() -> bool:
	return _eat_button.visible and not _eat_button.disabled


func get_eat_button_text() -> String:
	return _eat_button.text


func press_eat_button() -> void:
	if is_eat_button_enabled():
		_eat_button.pressed.emit()


func _selected_item() -> ItemData:
	return _slot_items.get(_selected_slot, null) if _selected_slot != null else null


func _on_slot_hovered(slot: Control) -> void:
	_show_item(_slot_items.get(slot, null))


func _on_slot_unhovered() -> void:
	_show_item(_selected_item())


func _on_slot_gui_input(event: InputEvent, slot: Control) -> void:
	var click: InputEventMouseButton = event as InputEventMouseButton
	if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		_select(slot)


func _select(slot: Control) -> void:
	_selected_slot = slot
	_show_item(_selected_item())
	_update_eat_button()


func _show_item(item: ItemData) -> void:
	_item_name.text = tr(item.name_key) if item != null else ""


## Eat button: only for food selected in the stash grid. Disabled with a reason when it cannot be eaten.
func _update_eat_button() -> void:
	var item: ItemData = _selected_item()
	var in_stash: bool = _selected_slot != null and _selected_slot.get_parent() == _stash_grid
	_eat_button.visible = item != null and in_stash and item.buff_max_health > 0
	if not _eat_button.visible:
		return
	_eat_button.disabled = not GameState.can_eat(item)
	if not _eat_button.disabled:
		_eat_button.text = tr(&"UI_EAT_FOOD") % item.buff_max_health
	elif GameState.max_health_buff > 0:
		_eat_button.text = tr(&"UI_EAT_ALREADY")
	else:
		_eat_button.text = tr(&"UI_EAT_TAVERN_ONLY")


func _on_eat_pressed() -> void:
	var item: ItemData = _selected_item()
	if item != null and GameState.eat_from_stash(item):
		EventBus.toast_requested.emit(tr(&"TOAST_ATE_FOOD") % [tr(item.name_key), item.buff_max_health])
	_refresh()
