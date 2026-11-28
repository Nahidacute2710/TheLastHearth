extends "res://tests/test_case.gd"
## VSA1: game fonts (Galmuri11 main, Galmuri9 HUD), shared theme, and the font preview debug screen.

const PREVIEW_SCENE: String = "res://scenes/debug/font_preview.tscn"
const THEME_PATH: String = "res://resources/ui/main_theme.tres"
const MAIN_FONT: String = "res://resources/ui/fnt_main.tres"
const HUD_FONT: String = "res://resources/ui/fnt_hud.tres"
const FontPreviewScript: GDScript = preload("res://scenes/debug/font_preview.gd")
## Rendered glyph images carry 1 px of padding on each side.
const GLYPH_PADDING: float = 1.0

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


func _all_text() -> String:
	var text: String = FontPreviewScript.DIACRITICS_SAMPLE + FontPreviewScript.CAPITALS_SAMPLE
	for row: PackedStringArray in FontPreviewScript.read_translation_rows():
		text += row[1] + row[2]
	return text


func test_theme_uses_galmuri_at_native_sizes() -> void:
	var theme: Theme = load(THEME_PATH) as Theme
	check_eq(ProjectSettings.get_setting("gui/theme/custom"), THEME_PATH, "project theme is set")
	check_eq(theme.default_font.resource_path, MAIN_FONT, "main font is Galmuri11")
	check_eq(theme.default_font_size, 12, "main font at its native 12 px")
	check_eq(theme.get_font(&"font", &"HudLabel").resource_path, HUD_FONT, "HUD font is Galmuri9")
	check_eq(theme.get_font_size(&"font_size", &"HudLabel"), 10, "HUD font at its native 10 px")
	check_eq(theme.get_font_size(&"font_size", &"TitleLabel") % 12, 0, "title is a whole multiple of 12 px")
	for path: String in [MAIN_FONT, HUD_FONT]:
		var base: FontFile = (load(path) as FontVariation).base_font as FontFile
		check_eq(base.antialiasing, TextServer.FONT_ANTIALIASING_NONE, "%s: no antialiasing" % path)
		check_eq(base.hinting, TextServer.HINTING_NONE, "%s: no hinting" % path)
		check_eq(base.subpixel_positioning, TextServer.SUBPIXEL_POSITIONING_DISABLED, "%s: no subpixel" % path)


func test_game_fonts_cover_every_character() -> void:
	var text: String = _all_text()
	for path: String in [MAIN_FONT, HUD_FONT]:
		var font: Font = load(path) as Font
		var missing: String = ""
		for i: int in text.length():
			var code: int = text.unicode_at(i)
			if code > 32 and not font.has_char(code) and not missing.contains(char(code)):
				missing += char(code)
		check_eq(missing, "", "%s has every character" % path)


func test_line_height_fits_capital_marks_and_descenders() -> void:
	var ts: TextServer = TextServerManager.get_primary_interface()
	for entry: Array in [[MAIN_FONT, 12], [HUD_FONT, 10]]:
		var font: Font = load(entry[0]) as Font
		var size: int = entry[1]
		var rid: RID = font.get_rids()[0]
		var top: float = 0.0
		var bottom: float = 0.0
		for c: String in FontPreviewScript.CAPITALS_SAMPLE + "ẦẪẶỔỰỠẲỄỸỮgjpqyỵ":
			var glyph: int = ts.font_get_glyph_index(rid, size, c.unicode_at(0), 0)
			ts.font_render_glyph(rid, Vector2i(size, 0), glyph)
			var offset: Vector2 = ts.font_get_glyph_offset(rid, Vector2i(size, 0), glyph)
			var glyph_size: Vector2 = ts.font_get_glyph_size(rid, Vector2i(size, 0), glyph)
			top = maxf(top, -offset.y - GLYPH_PADDING)
			bottom = maxf(bottom, offset.y + glyph_size.y - GLYPH_PADDING)
		check(font.get_ascent(size) >= top, "%s: capital marks fit above the line (%s > %s)" % [entry[0], top, font.get_ascent(size)])
		check(font.get_descent(size) >= bottom, "%s: descenders fit below the line" % entry[0])


func test_preview_lists_every_string_in_vietnamese_first() -> void:
	var preview: Control = await _open_preview()
	var rows: Array[PackedStringArray] = FontPreviewScript.read_translation_rows()
	var texts: Array[String] = preview.call("get_row_texts")
	check_eq(texts.size(), rows.size(), "one row per translation key")
	check_eq(preview.call("get_language"), "VI", "starts in Vietnamese")
	check_eq(texts[1], rows[1][2], "rows show the vi column")
	check(str(preview.call("get_header_text")).contains("Galmuri11"), "header names the main font")


func test_preview_switches_font_and_language_on_screen() -> void:
	var preview: Control = await _open_preview()
	var first_font: Font = preview.call("get_row_font")
	preview.call("next_font", 1)
	check(str(preview.call("get_font_name")).begins_with("Galmuri9"), "right goes to the HUD font")
	check(preview.call("get_row_font") != first_font, "rows are redrawn with the new font")
	check(str(preview.call("get_header_text")).contains("Galmuri9"), "header shows the new font")
	preview.call("next_font", 1)
	check(str(preview.call("get_font_name")).begins_with("Galmuri11"), "wraps around to the first font")
	preview.call("toggle_language")
	await tree.process_frame
	var rows: Array[PackedStringArray] = FontPreviewScript.read_translation_rows()
	var texts: Array[String] = preview.call("get_row_texts")
	check_eq(preview.call("get_language"), "EN", "accept switches to English")
	check_eq(texts[1], rows[1][1], "rows show the en column")
	check(str(preview.call("get_header_text")).contains("[EN]"), "header shows the language")
