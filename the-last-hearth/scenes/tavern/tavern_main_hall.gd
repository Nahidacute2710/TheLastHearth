extends Node2D
## Tavern main hall graybox (milestone 1.2). Passes the room bounds down to the player camera.

@onready var _floor: TileMapLayer = %Floor
@onready var _player: Player = %Player


func _ready() -> void:
	_player.set_camera_limits(_get_room_rect_px())


## get_used_rect() is in tile coordinates; convert to pixels before using it for the camera.
func _get_room_rect_px() -> Rect2i:
	var used_tiles: Rect2i = _floor.get_used_rect()
	var tile_size: Vector2i = _floor.tile_set.tile_size
	var layer_origin: Vector2i = Vector2i(_floor.position)
	return Rect2i(layer_origin + used_tiles.position * tile_size, used_tiles.size * tile_size)
