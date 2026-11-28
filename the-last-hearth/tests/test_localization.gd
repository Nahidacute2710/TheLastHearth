extends "res://tests/test_case.gd"


func test_translations_exist_in_english_and_vietnamese() -> void:
	TranslationServer.set_locale("en")
	check_eq(TranslationServer.translate(&"PROMPT_ENTER_MINE"), "Go down to the mine", "EN prompt")
	TranslationServer.set_locale("vi")
	check_eq(TranslationServer.translate(&"PROMPT_ENTER_MINE"), "Xuống mỏ", "VI prompt")
	check_eq(TranslationServer.translate(&"UI_PROMPT_FORMAT") % ["E", "x"], "[E] x", "prompt format")


## Every key has a Vietnamese text with the same placeholders as English.
func test_every_key_has_vietnamese_with_matching_placeholders() -> void:
	var file: FileAccess = FileAccess.open("res://localization/translations.csv", FileAccess.READ)
	var header: PackedStringArray = file.get_csv_line()
	check_eq(header, PackedStringArray(["keys", "en", "vi"]), "columns are keys,en,vi")
	var count: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() == 1 and row[0] == "":
			continue
		count += 1
		check_eq(row.size(), 3, "row %s has 3 columns" % row[0])
		if row.size() < 3:
			continue
		check(row[2].strip_edges() != "", "%s has a Vietnamese text" % row[0])
		for placeholder: String in ["%s", "%d"]:
			check_eq(row[2].count(placeholder), row[1].count(placeholder), "%s: same %s count in en and vi" % [row[0], placeholder])
	check(count >= 37, "all keys read (%d)" % count)
