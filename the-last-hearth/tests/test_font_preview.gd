extends "res://tests/test_case.gd"

const PREVIEW_SCENE: String = "res://scenes/debug/font_preview.tscn"
const FontPreviewScript: GDScript = preload("res://scenes/debug/font_preview.gd")

var _preview: Control = null


func after_each() -> void:
	if _preview != null:
		_preview.queue_free()
		_preview = null
	await super()


func _open_preview() -> Control:
	_preview = (load(PREVIEW_SCENE) as PackedScene).instantiate() as Control
	tree.root.add_child(_preview)
	await tree.process_frame
	return _preview


func test_every_candidate_covers_all_translation_characters() -> void:
	var rows: Array[PackedStringArray] = FontPreviewScript.read_translation_rows()
	check(rows.size() > 30, "translations.csv rows are read")
	var text: String = FontPreviewScript.DIACRITICS_SAMPLE + FontPreviewScript.CAPITALS_SAMPLE
	for row: PackedStringArray in rows:
		text += row[1] + row[2]
	for candidate: Dictionary in FontPreviewScript.CANDIDATES:
		var font: FontFile = FontPreviewScript.load_candidate_font(candidate["path"])
		check(font != null, "%s loads" % candidate["name"])
		if font == null:
			continue
		check_eq(font.antialiasing, TextServer.FONT_ANTIALIASING_NONE, "%s has no antialiasing" % candidate["name"])
		var missing: String = ""
		for i: int in text.length():
			var code: int = text.unicode_at(i)
			if code > 32 and not font.has_char(code) and not missing.contains(char(code)):
				missing += char(code)
		check_eq(missing, "", "%s has every character" % candidate["name"])


func test_preview_lists_every_string_in_vietnamese_first() -> void:
	var preview: Control = await _open_preview()
	var rows: Array[PackedStringArray] = FontPreviewScript.read_translation_rows()
	var texts: Array[String] = preview.call("get_row_texts")
	check_eq(texts.size(), rows.size(), "one row per translation key")
	check_eq(preview.call("get_language"), "VI", "starts in Vietnamese")
	check_eq(texts[1], rows[1][2], "rows show the vi column")
	check(str(preview.call("get_header_text")).contains("Galmuri11"), "header names the first font")


func test_preview_switches_font_and_language_on_screen() -> void:
	var preview: Control = await _open_preview()
	var first_font: Font = preview.call("get_row_font")
	preview.call("next_font", 1)
	check_eq(preview.call("get_font_name"), "Galmuri9", "right goes to the next font")
	check(preview.call("get_row_font") != first_font, "rows are redrawn with the new font")
	check(str(preview.call("get_header_text")).contains("Galmuri9"), "header shows the new font")
	preview.call("next_font", -2)
	check_eq(preview.call("get_font_name"), "VT323", "left wraps around to the last font")
	preview.call("toggle_language")
	await tree.process_frame
	var rows: Array[PackedStringArray] = FontPreviewScript.read_translation_rows()
	var texts: Array[String] = preview.call("get_row_texts")
	check_eq(preview.call("get_language"), "EN", "accept switches to English")
	check_eq(texts[1], rows[1][1], "rows show the en column")
	check(str(preview.call("get_header_text")).contains("[EN]"), "header shows the language")
