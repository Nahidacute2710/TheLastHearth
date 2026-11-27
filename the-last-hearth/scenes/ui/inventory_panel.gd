extends Control
## Bag + tavern stash panel. The `inventory` action (Tab, I) opens and closes it; `pause` (Esc) closes it.
## The world is paused while it is open. Input is read in _input and marked handled, so Tab never
## reaches GUI focus navigation (TECH-006). No control in the panel can take focus.

const SLOT_SIZE: Vector2 = Vector2(20.0, 20.0)
const SLOT_COLOR: Color = Color(0.16, 0.13, 0.15)
const SLOT_BORDER: Color = Color(0.0862745, 0.0784314, 0.109804)

@export var label_settings: LabelSettings

@onready var _bag_grid: GridContainer = %BagGrid
@onready var _stash_grid: GridContainer = %StashGrid


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	GameState.bag.changed.connect(_refresh)
	GameState.stash.changed.connect(_refresh)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"inventory") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if visible:
			close()
		elif not SceneRouter.is_transitioning():
			open()
	elif visible and event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		close()


func open() -> void:
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
			slot.tooltip_text = stacks[i].item.name_key
		else:
			icon.texture = null
			count.text = ""
			slot.tooltip_text = ""


func _make_slot() -> Control:
	var slot: Panel = Panel.new()
	slot.custom_minimum_size = SLOT_SIZE
	slot.focus_mode = Control.FOCUS_NONE
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
