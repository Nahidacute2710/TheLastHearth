class_name AudioDirector
extends Node
## Plays sound effects by id on the SFX bus. Lives in Main ("call down, signal up"): gameplay code emits
## EventBus.sfx_requested(id); every Button in the tree plays "ui_click" when pressed.
## Runs while the game is paused (menus). Sounds come from an SfxLibrary resource.

const POOL_SIZE: int = 8
const SFX_BUS: StringName = &"SFX"
const UI_CLICK: StringName = &"ui_click"
const HISTORY_SIZE: int = 32

@export var library: SfxLibrary

## Last played ids, newest last (tests).
var played: Array[StringName] = []

var _players: Array[AudioStreamPlayer] = []
var _next_player: int = 0
var _warned: Dictionary[StringName, bool] = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i: int in POOL_SIZE:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		_players.append(player)
	EventBus.sfx_requested.connect(play)
	get_tree().node_added.connect(_on_node_added)
	_hook_buttons_in(get_tree().root)


func play(id: StringName) -> void:
	var stream: AudioStream = library.get_stream(id) if library != null else null
	if stream == null:
		if not _warned.has(id):
			_warned[id] = true
			push_warning("AudioDirector: no sound for id '%s'." % id)
		return
	var player: AudioStreamPlayer = _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = stream
	player.volume_db = library.volume_db.get(id, 0.0)
	player.play()
	played.append(id)
	if played.size() > HISTORY_SIZE:
		played.pop_front()


func get_player_bus() -> StringName:
	return _players[0].bus


func _hook_buttons_in(node: Node) -> void:
	_on_node_added(node)
	for child: Node in node.get_children():
		_hook_buttons_in(child)


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		var button: BaseButton = node as BaseButton
		if not button.pressed.is_connected(_on_button_pressed):
			button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	play(UI_CLICK)
