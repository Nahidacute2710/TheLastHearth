extends VBoxContainer
## Short messages at the bottom of the screen (e.g. "Stored 3 Cave Mushroom"). Text comes from translation keys.

const SHOW_TIME: float = 2.0
const FADE_TIME: float = 0.4
const MAX_LINES: int = 4

@export var label_settings: LabelSettings


func _ready() -> void:
	EventBus.items_stored.connect(_on_items_stored)
	EventBus.toast_requested.connect(show_message)


func show_message(message: String) -> void:
	while get_child_count() >= MAX_LINES:
		var oldest: Node = get_child(0)
		remove_child(oldest)
		oldest.queue_free()
	var line: Label = Label.new()
	line.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	line.label_settings = label_settings
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	line.text = message
	add_child(line)
	var tween: Tween = line.create_tween()
	tween.tween_interval(SHOW_TIME)
	tween.tween_property(line, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(line.queue_free)


func get_messages() -> PackedStringArray:
	var messages: PackedStringArray = []
	for child: Node in get_children():
		if child is Label and not child.is_queued_for_deletion():
			messages.append((child as Label).text)
	return messages


func _on_items_stored(item: ItemData, count: int) -> void:
	show_message(tr(&"TOAST_ITEMS_STORED") % [count, tr(item.name_key)])
