class_name HearthPanel
extends Control
## Hearth Flame panel, opened from the fireplace. Shows the level, the next level's cost (gold and
## Ember Coal in the stash: have / need), what it unlocks and a Kindle button that is disabled, with
## the reason, until the cost is met. At the max level it says so. Below: the parts of the previous
## owner's letter revealed so far, newest last. Pauses the world; Esc (pause) or Close closes it.

const LETTER_GAP: int = 6

@onready var _level_label: Label = %LevelLabel
@onready var _next_box: Control = %NextBox
@onready var _next_title: Label = %NextTitle
@onready var _unlock_label: Label = %UnlockLabel
@onready var _gold_label: Label = %GoldLabel
@onready var _ember_label: Label = %EmberLabel
@onready var _kindle_button: Button = %KindleButton
@onready var _block_label: Label = %BlockLabel
@onready var _max_label: Label = %MaxLabel
@onready var _letter_scroll: ScrollContainer = %LetterScroll
@onready var _letter_list: VBoxContainer = %LetterList
@onready var _close_button: Button = %CloseButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	EventBus.hearth_panel_requested.connect(open)
	EventBus.hearth_level_changed.connect(_on_state_changed)
	EventBus.gold_changed.connect(_on_state_changed)
	GameState.stash.changed.connect(_refresh)
	_kindle_button.pressed.connect(_on_kindle_pressed)
	_close_button.pressed.connect(close)


func _input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel")) and not event.is_echo():
		get_viewport().set_input_as_handled()
		close()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()


func open() -> void:
	if visible or get_tree().paused:
		return
	_refresh()
	show()
	get_tree().paused = true
	if _kindle_button.visible and not _kindle_button.disabled:
		_kindle_button.grab_focus()
	else:
		_close_button.grab_focus()
	_scroll_to_newest_letter()


func close() -> void:
	if not visible:
		return
	hide()
	get_tree().paused = false


func is_open() -> bool:
	return visible


func get_level_text() -> String:
	return _level_label.text


func get_unlock_text() -> String:
	return _unlock_label.text if _next_box.visible else ""


func get_gold_text() -> String:
	return _gold_label.text if _next_box.visible else ""


func get_ember_text() -> String:
	return _ember_label.text if _next_box.visible else ""


func is_kindle_enabled() -> bool:
	return _next_box.visible and not _kindle_button.disabled


func get_block_text() -> String:
	return _block_label.text if _next_box.visible else ""


func is_max_level_shown() -> bool:
	return _max_label.visible


func get_letter_texts() -> PackedStringArray:
	var texts: PackedStringArray = []
	for child: Node in _letter_list.get_children():
		if child is Label and not child.is_queued_for_deletion():
			texts.append((child as Label).text)
	return texts


func press_kindle() -> void:
	if not _kindle_button.disabled:
		_kindle_button.pressed.emit()


func _on_kindle_pressed() -> void:
	if GameState.kindle_hearth():
		_refresh()
		_scroll_to_newest_letter()
		_close_button.grab_focus()


func _on_state_changed(_value: int) -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	var table: HearthTable = GameState.get_hearth_table()
	_level_label.text = tr(&"HEARTH_LEVEL") % [GameState.hearth_level, table.max_level()]
	var next: HearthLevelData = GameState.get_next_hearth_level()
	_next_box.visible = next != null
	_max_label.visible = next == null
	if next != null:
		var have_gold: int = GameState.gold
		var have_ember: int = GameState.stash.count_of(table.cost_item)
		_next_title.text = tr(&"HEARTH_NEXT_LEVEL") % next.level
		_unlock_label.text = tr(&"HEARTH_UNLOCKS") % tr(next.unlock_key)
		_gold_label.text = tr(&"HEARTH_COST_GOLD") % [have_gold, next.gold_cost]
		_gold_label.theme_type_variation = &"" if have_gold >= next.gold_cost else &"ErrorLabel"
		_ember_label.text = tr(&"HEARTH_COST_ITEM") % [tr(table.cost_item.name_key), have_ember, next.ember_cost]
		_ember_label.theme_type_variation = &"" if have_ember >= next.ember_cost else &"ErrorLabel"
		var block: StringName = GameState.get_kindle_block()
		_kindle_button.disabled = block != GameState.KINDLE_OK
		_block_label.text = _block_text(block)
	_fill_letters()


func _block_text(block: StringName) -> String:
	match block:
		GameState.KINDLE_NEED_GOLD:
			return tr(&"HEARTH_BLOCK_GOLD")
		GameState.KINDLE_NEED_EMBER:
			return tr(&"HEARTH_BLOCK_EMBER")
	return ""


func _fill_letters() -> void:
	for child: Node in _letter_list.get_children():
		_letter_list.remove_child(child)
		child.queue_free()
	var keys: Array[StringName] = GameState.hearth_letters
	if keys.is_empty():
		_letter_list.add_child(_make_letter_label(tr(&"HEARTH_NO_LETTER"), true))
		return
	for key: StringName in keys:
		_letter_list.add_child(_make_letter_label(tr(key), false))


func _make_letter_label(text: String, hint: bool) -> Label:
	var label: Label = Label.new()
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = text
	if hint:
		label.modulate = Color(1.0, 1.0, 1.0, 0.6)
	return label


func _scroll_to_newest_letter() -> void:
	await get_tree().process_frame
	if is_instance_valid(_letter_scroll):
		_letter_scroll.scroll_vertical = int(_letter_scroll.get_v_scroll_bar().max_value)
