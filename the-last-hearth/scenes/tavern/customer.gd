extends Node2D
## A customer who visits once per day and waits (forever) for one dish from the tavern stash.
## Whether today's visit is done is stored in GameState, so it survives level reloads.

@export var data: CustomerData

@onready var _sprite: Sprite2D = $Sprite
@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	_sprite.texture = data.sprite
	_interactable.interacted.connect(_on_interacted)
	EventBus.day_changed.connect(_on_day_changed)
	_refresh()


func is_present() -> bool:
	return visible


func _on_interacted(_actor: Node2D) -> void:
	if not GameState.stash.remove(data.wanted_item, 1):
		EventBus.toast_requested.emit(tr(&"TOAST_CUSTOMER_WAITING") % [tr(data.name_key), tr(data.wanted_item.name_key)])
		return
	GameState.add_gold(data.payment)
	GameState.mark_customer_served(data.id)
	EventBus.toast_requested.emit(tr(&"TOAST_CUSTOMER_PAID") % [tr(data.name_key), data.payment])
	_refresh()


func _on_day_changed(_day: int) -> void:
	_refresh()


func _refresh() -> void:
	var present: bool = not GameState.is_customer_served_today(data.id)
	visible = present
	_interactable.enabled = present
