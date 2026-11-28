extends Node2D
## A customer who visits once per day and waits (forever) for one dish from the tavern stash.
## Whether today's visit is done is stored in GameState, so it survives level reloads.

@export var data: CustomerData
## Seat number. Seat 1 is always open; higher seats open with the Hearth Flame (level 3: seat 2).
@export var seat: int = 1

@onready var _sprite: Sprite2D = $Sprite
@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	_sprite.texture = data.sprite
	_interactable.interacted.connect(_on_interacted)
	EventBus.day_changed.connect(_on_day_changed)
	EventBus.hearth_level_changed.connect(_on_day_changed)
	_refresh()


func is_present() -> bool:
	return visible


## Key for "served today" in GameState: seat 1 keeps the plain customer id (old saves), other seats add the seat.
func get_visit_id() -> StringName:
	return data.id if seat <= 1 else StringName("%s_%d" % [data.id, seat])


func _on_interacted(_actor: Node2D) -> void:
	if not GameState.stash.remove(data.wanted_item, 1):
		EventBus.toast_requested.emit(tr(&"TOAST_CUSTOMER_WAITING") % [tr(data.name_key), tr(data.wanted_item.name_key)])
		return
	GameState.add_gold(data.payment)
	EventBus.sfx_requested.emit(&"coin")
	GameState.mark_customer_served(get_visit_id())
	EventBus.toast_requested.emit(tr(&"TOAST_CUSTOMER_PAID") % [tr(data.name_key), data.payment])
	_refresh()


func _on_day_changed(_day: int) -> void:
	_refresh()


func _refresh() -> void:
	var present: bool = seat <= GameState.get_customer_slots() and not GameState.is_customer_served_today(get_visit_id())
	visible = present
	_interactable.enabled = present
