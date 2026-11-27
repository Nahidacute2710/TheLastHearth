extends VBoxContainer
## Top-right "Day X" and gold. Text comes from translation keys and refreshes on locale change.

@onready var _day_label: Label = %DayLabel
@onready var _gold_label: Label = %GoldLabel


func _ready() -> void:
	EventBus.day_changed.connect(_on_changed)
	EventBus.gold_changed.connect(_on_changed)
	_refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()


func get_day_text() -> String:
	return _day_label.text


func get_gold_text() -> String:
	return _gold_label.text


func _on_changed(_value: int) -> void:
	_refresh()


func _refresh() -> void:
	_day_label.text = tr(&"HUD_DAY") % GameState.day
	_gold_label.text = tr(&"HUD_GOLD") % GameState.gold
