extends Node
## Debug-only hotkeys for quick playtesting. Freed immediately in release builds.
## F1: toggle EN/VI · F2: go to the mine · F3: go to the tavern.


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.physical_keycode:
		KEY_F1:
			var next_locale: String = "en" if TranslationServer.get_locale().begins_with("vi") else "vi"
			TranslationServer.set_locale(next_locale)
			print("Debug: locale = %s" % next_locale)
		KEY_F2:
			SceneRouter.go_to(SceneRouter.DUNGEON, &"entrance")
		KEY_F3:
			SceneRouter.go_to(SceneRouter.TAVERN, &"cellar_door")
