extends "res://tests/test_case.gd"


func test_translations_exist_in_english_and_vietnamese() -> void:
	TranslationServer.set_locale("en")
	check_eq(TranslationServer.translate(&"PROMPT_ENTER_MINE"), "Go down to the mine", "EN prompt")
	TranslationServer.set_locale("vi")
	check_eq(TranslationServer.translate(&"PROMPT_ENTER_MINE"), "Xuống mỏ", "VI prompt")
	check_eq(TranslationServer.translate(&"UI_PROMPT_FORMAT") % ["E", "x"], "[E] x", "prompt format")
