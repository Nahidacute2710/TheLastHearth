class_name SfxLibrary
extends Resource
## Sound id -> stream. Code plays sounds by id only (EventBus.sfx_requested); swapping a placeholder for
## a real, licensed file is done here in data/audio/sfx_library.tres, with no code change.

## Ids the game plays. A test checks that each one has a stream.
const IDS: Array[StringName] = [
	&"swing", &"hit", &"enemy_windup", &"dodge", &"pickup", &"cook_done", &"coin", &"ui_click",
	&"ore_hit", &"ore_break", &"hearth_kindle",
]

@export var sounds: Dictionary[StringName, AudioStream] = {}
## Optional per-sound volume offset in dB (missing = 0).
@export var volume_db: Dictionary[StringName, float] = {}


func get_stream(id: StringName) -> AudioStream:
	return sounds.get(id, null)
