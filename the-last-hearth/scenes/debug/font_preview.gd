class_name FontPreview
extends Control
## Debug screen (VS-A): shows every string of translations.csv with the game's fonts (as used by the
## UI theme), at the game's 640x360 resolution, to check Vietnamese text by eye.
## Keys: left/right change font, accept toggles EN/VI, up/down scroll, cancel quits.

const CSV_PATH: String = "res://localization/translations.csv"
const DIACRITICS_SAMPLE: String = "ầ ẫ ặ ổ ự ỡ ẳ ễ ị ỹ   Ầ Ẫ Ặ Ổ Ự Ỡ Ẳ Ễ Ị Ỹ   Đ đ Ơ ơ Ư ư Ă ă Â â Ê ê Ô ô"
const CANDIDATES: Array[Dictionary] = [
	{"name": "Galmuri11 (main)", "path": "res://resources/ui/fnt_main.tres", "size": 12, "gap": 0, "license": "SIL OFL 1.1"},
	{"name": "Galmuri9 (HUD)", "path": "res://resources/ui/fnt_hud.tres", "size": 10, "gap": 0, "license": "SIL OFL 1.1"},
]
## Capital words with stacked marks: shows whether marks collide with the line above.
const CAPITALS_SAMPLE: String = "QUẢN ĐỐC RỖNG  CỬA HẦM  NGỌN LỬA GỐC  ẨM ƯỚT  Ở ĐÂY"
## Space above the first row (the game fonts already reserve room for capital marks).
const TOP_PADDING: int = 2
const LANGUAGES: Array[String] = ["EN", "VI"]
const SCROLL_STEP: int = 24
const TEXT_COLOR: Color = Color(0.92, 0.88, 0.8)

var _font_index: int = 0
var _language_index: int = 1
var _rows: Array[PackedStringArray] = []
var _label_settings: LabelSettings = LabelSettings.new()

@onready var _header: Label = %Header
@onready var _scroll: ScrollContainer = %Scroll
@onready var _list: VBoxContainer = %List


func _ready() -> void:
	_rows = _read_csv_rows()
	_label_settings.font_color = TEXT_COLOR
	_rebuild()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_right"):
		next_font(1)
	elif event.is_action_pressed(&"ui_left"):
		next_font(-1)
	elif event.is_action_pressed(&"ui_accept"):
		toggle_language()
	elif event.is_action_pressed(&"ui_down"):
		_scroll.scroll_vertical += SCROLL_STEP
	elif event.is_action_pressed(&"ui_up"):
		_scroll.scroll_vertical -= SCROLL_STEP
	elif event.is_action_pressed(&"ui_cancel"):
		get_tree().quit()
	else:
		return
	get_viewport().set_input_as_handled()


func next_font(step: int) -> void:
	_font_index = wrapi(_font_index + step, 0, CANDIDATES.size())
	_rebuild()


func toggle_language() -> void:
	_language_index = 1 - _language_index
	_rebuild()


func get_font_name() -> String:
	return CANDIDATES[_font_index]["name"]


func get_language() -> String:
	return LANGUAGES[_language_index]


func get_header_text() -> String:
	return _header.text


## Texts of the string rows (sample line excluded), in display order.
func get_row_texts() -> Array[String]:
	var texts: Array[String] = []
	for child: Node in _list.get_children():
		if not String(child.name).begins_with("Sample"):
			texts.append((child as Label).text)
	return texts


## The font the rows are drawn with right now.
func get_row_font() -> Font:
	return _label_settings.font


## Loads one of the game fonts (a FontVariation over a FontFile imported without antialiasing).
static func load_preview_font(path: String) -> Font:
	return load(path) as Font


## CSV rows without the header: [key, en, vi].
static func read_translation_rows() -> Array[PackedStringArray]:
	var rows: Array[PackedStringArray] = []
	var file: FileAccess = FileAccess.open(CSV_PATH, FileAccess.READ)
	if file == null:
		push_warning("FontPreview: cannot open %s" % CSV_PATH)
		return rows
	file.get_csv_line()
	while not file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		if line.size() >= 3 and line[0] != "":
			rows.append(line)
	return rows


func _read_csv_rows() -> Array[PackedStringArray]:
	return read_translation_rows()


func _rebuild() -> void:
	var candidate: Dictionary = CANDIDATES[_font_index]
	_label_settings.font = load_preview_font(candidate["path"])
	_label_settings.font_size = candidate["size"]
	_list.add_theme_constant_override(&"separation", candidate["gap"])
	_header.text = "%s  %d px  %s  [%s]   <- -> font   Enter EN/VI   Up/Down scroll   Esc quit" % [
		candidate["name"], candidate["size"], candidate["license"], get_language()]
	for child: Node in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	var padding: Control = Control.new()
	padding.name = &"SamplePadding"
	padding.custom_minimum_size = Vector2(0, TOP_PADDING)
	_list.add_child(padding)
	_list.add_child(_make_label(DIACRITICS_SAMPLE, &"SampleMarks"))
	_list.add_child(_make_label(CAPITALS_SAMPLE, &"SampleCapitals"))
	var column: int = 1 + _language_index
	for row: PackedStringArray in _rows:
		_list.add_child(_make_label(row[column], StringName(row[0])))
	_scroll.scroll_vertical = 0


func _make_label(text: String, node_name: StringName) -> Label:
	var label: Label = Label.new()
	label.name = node_name
	label.text = text
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.label_settings = _label_settings
	return label
