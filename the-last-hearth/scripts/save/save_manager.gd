extends Node
## Reads and writes the JSON save (one slot). Writes go to a .tmp file first, then replace the save.
## A save that cannot be read (bad JSON, empty, missing fields, unknown save_version) is renamed to
## .bak and reported, never applied, and never crashes the game.
## Saved: day, gold, stash, equipped weapon, served customers, food buff. Not saved: player position, bag.
## Player settings (language, volumes, fullscreen, keys) live apart in user://settings.cfg (GameSettings),
## so "New Game" never resets them. Saves from before VS-A kept the language in "settings.locale":
## it is read once, when no settings file exists yet, and moved to settings.cfg.

enum LoadResult { OK, NO_SAVE, CORRUPT, UNSUPPORTED_VERSION }

const SAVE_VERSION: int = 1
const SAVE_DIR: String = "user://saves/"
const SAVE_FILE_NAME: String = "slot_1.json"
const GAME_VERSION_FALLBACK: String = "0.1.0"
const SETTINGS_DIR: String = "user://"
const SETTINGS_FILE_NAME: String = "settings.cfg"

## Changeable so tests never touch the real save.
var save_dir: String = SAVE_DIR
## Autosave is ignored while false (tests, or before a game has started).
var autosave_enabled: bool = true
## Changeable so tests never touch the real settings.
var settings_dir: String = SETTINGS_DIR
var settings: GameSettings = null

## Translation key describing the last load problem, or &"" (shown by the main menu).
var last_error_key: StringName = &""


func _ready() -> void:
	settings = GameSettings.new()
	EventBus.autosave_requested.connect(_on_autosave_requested)


func get_settings_path() -> String:
	return settings_dir.path_join(SETTINGS_FILE_NAME)


## Reads settings.cfg (or migrates the language from an old save) and applies everything.
## A missing or unreadable file gives defaults and never crashes.
func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	if FileAccess.file_exists(get_settings_path()) and config.load(get_settings_path()) == OK:
		settings.from_config(config)
	else:
		if FileAccess.file_exists(get_settings_path()):
			push_warning("SaveManager: unreadable settings file, using defaults.")
		settings.reset_to_defaults()
		var migrated: String = _locale_from_old_save()
		if migrated != "":
			settings.locale = migrated
		save_settings()
	settings.apply()


func save_settings() -> bool:
	DirAccess.make_dir_recursive_absolute(settings_dir)
	var error: Error = settings.to_config().save(get_settings_path())
	if error != OK:
		push_error("SaveManager: cannot write settings (%s)." % error_string(error))
		return false
	return true


## Back to defaults in memory and in the engine, without writing the file (tests).
func reset_settings() -> void:
	settings.reset_to_defaults()
	settings.apply()


func set_locale(locale: String) -> void:
	var code: String = GameSettings.normalize_locale(locale)
	if code == "":
		return
	settings.locale = code
	settings.apply_locale()
	save_settings()


func set_volume(bus: StringName, linear: float) -> void:
	settings.volumes[bus] = clampf(linear, 0.0, 1.0)
	settings.apply_volume(bus)
	save_settings()


func set_fullscreen(enabled: bool) -> void:
	settings.fullscreen = enabled
	settings.apply_fullscreen()
	save_settings()


## Returns the action already using the input (nothing changed), or &"" when the binding was saved.
func rebind_action(action: StringName, event: InputEvent) -> StringName:
	var conflict: StringName = settings.rebind(action, event)
	if conflict == &"":
		save_settings()
	return conflict


func reset_key_bindings() -> void:
	settings.reset_bindings()
	save_settings()


func get_save_path() -> String:
	return save_dir.path_join(SAVE_FILE_NAME)


func get_backup_path() -> String:
	return get_save_path() + ".bak"


func has_save_file() -> bool:
	return FileAccess.file_exists(get_save_path())


func save_game() -> bool:
	var data: Dictionary = {
		"save_version": SAVE_VERSION,
		"game_version": _game_version(),
		"timestamp": Time.get_datetime_string_from_system(),
		"game_state": GameState.to_dict(),
	}
	DirAccess.make_dir_recursive_absolute(save_dir)
	var tmp_path: String = get_save_path() + ".tmp"
	var file: FileAccess = FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot write %s (%s)." % [tmp_path, error_string(FileAccess.get_open_error())])
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	var error: Error = DirAccess.rename_absolute(tmp_path, get_save_path())
	if error != OK:
		push_error("SaveManager: cannot replace the save (%s)." % error_string(error))
		return false
	return true


## Reads and validates the save without applying it. Returns {"result": LoadResult, "data": Dictionary}.
func read_save() -> Dictionary:
	if not has_save_file():
		return {"result": LoadResult.NO_SAVE, "data": {}}
	var text: String = FileAccess.get_file_as_string(get_save_path())
	var json: JSON = JSON.new()
	if text.strip_edges().is_empty() or json.parse(text) != OK or not json.data is Dictionary:
		return {"result": LoadResult.CORRUPT, "data": {}}
	var data: Dictionary = json.data as Dictionary
	var version: Variant = data.get("save_version")
	if not (version is float or version is int):
		return {"result": LoadResult.CORRUPT, "data": {}}
	if int(version) != SAVE_VERSION:
		return {"result": LoadResult.UNSUPPORTED_VERSION, "data": {}}
	if not _is_valid_game_state(data.get("game_state")):
		return {"result": LoadResult.CORRUPT, "data": {}}
	return {"result": LoadResult.OK, "data": data}


## Checks the save at boot. A bad file is moved to .bak and last_error_key is set.
## Returns true when a valid save exists (the menu then offers "Continue").
func check_save() -> bool:
	last_error_key = &""
	var result: LoadResult = read_save()["result"]
	match result:
		LoadResult.OK:
			return true
		LoadResult.CORRUPT:
			_backup_bad_save()
			last_error_key = &"MENU_ERROR_SAVE_CORRUPT"
		LoadResult.UNSUPPORTED_VERSION:
			_backup_bad_save()
			last_error_key = &"MENU_ERROR_SAVE_VERSION"
	return false


## Applies the save to GameState. Returns the LoadResult. Settings are not part of the save.
func load_game() -> LoadResult:
	var read: Dictionary = read_save()
	var result: LoadResult = read["result"]
	if result != LoadResult.OK:
		return result
	var data: Dictionary = read["data"]
	GameState.from_dict(data["game_state"] as Dictionary)
	return LoadResult.OK


## Language stored by saves from before VS-A, or "". The save file itself is left untouched.
func _locale_from_old_save() -> String:
	var read: Dictionary = read_save()
	if read["result"] != LoadResult.OK:
		return ""
	var old: Variant = (read["data"] as Dictionary).get("settings")
	if not old is Dictionary:
		return ""
	return GameSettings.normalize_locale(str((old as Dictionary).get("locale", "")))


func delete_save() -> void:
	for path: String in [get_save_path(), get_save_path() + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _backup_bad_save() -> void:
	if FileAccess.file_exists(get_backup_path()):
		DirAccess.remove_absolute(get_backup_path())
	var error: Error = DirAccess.rename_absolute(get_save_path(), get_backup_path())
	if error != OK:
		push_error("SaveManager: cannot back up the bad save (%s)." % error_string(error))
	else:
		push_warning("SaveManager: unreadable save moved to %s." % get_backup_path())


func _is_valid_game_state(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var state: Dictionary = value as Dictionary
	for key: String in ["day", "gold"]:
		if not (state.get(key) is float or state.get(key) is int):
			return false
	if not state.get("equipped_weapon") is String or not state.get("stash") is Array:
		return false
	var weapon_id: String = state["equipped_weapon"]
	if weapon_id != "" and not ItemDB.has_item(StringName(weapon_id)):
		return false
	for entry: Variant in state["stash"]:
		if not entry is Dictionary or not (entry as Dictionary).get("id") is String:
			return false
	if state.has("customer_served_day") and not state["customer_served_day"] is Dictionary:
		return false
	if state.has("max_health_buff") and not (state["max_health_buff"] is float or state["max_health_buff"] is int):
		return false
	return true


func _game_version() -> String:
	var version: String = str(ProjectSettings.get_setting("application/config/version", ""))
	return version if version != "" else GAME_VERSION_FALLBACK


func _on_autosave_requested() -> void:
	if autosave_enabled and SceneRouter.current_level_id == SceneRouter.TAVERN:
		save_game()
