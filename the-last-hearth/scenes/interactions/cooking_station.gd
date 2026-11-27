extends Node2D
## Stove in the tavern. Interacting cooks the recipe from the tavern stash; the dish goes back into the stash.
## Shows a placeholder progress bar while cooking. Leaving the tavern mid-cook finishes the dish at once.

const BAR_SIZE: Vector2 = Vector2(24.0, 3.0)
const BAR_OFFSET: Vector2 = Vector2(-12.0, -38.0)
const BAR_BACK: Color = Color(0.0862745, 0.0784314, 0.109804)
const BAR_FILL: Color = Color(0.95, 0.69, 0.29)

@export var recipe: RecipeData

var _time_left: float = 0.0
var _cooking: bool = false

@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)


func _process(delta: float) -> void:
	if not _cooking:
		return
	_time_left -= delta
	queue_redraw()
	if _time_left <= 0.0:
		_finish()


func _exit_tree() -> void:
	if _cooking:
		_finish()


func is_cooking() -> bool:
	return _cooking


## 0..1 while cooking.
func get_progress() -> float:
	return 1.0 - _time_left / recipe.cook_time if _cooking else 0.0


func _draw() -> void:
	if not _cooking:
		return
	draw_rect(Rect2(BAR_OFFSET, BAR_SIZE).grow(1.0), BAR_BACK)
	draw_rect(Rect2(BAR_OFFSET, Vector2(BAR_SIZE.x * get_progress(), BAR_SIZE.y)), BAR_FILL)


func _on_interacted(_actor: Node2D) -> void:
	if _cooking or recipe == null:
		return
	if not recipe.take_ingredients(GameState.stash):
		var first: RecipeIngredient = recipe.ingredients[0]
		EventBus.toast_requested.emit(tr(&"TOAST_MISSING_INGREDIENTS") % [first.count, tr(first.item.name_key)])
		return
	_cooking = true
	_time_left = recipe.cook_time
	_interactable.enabled = false
	queue_redraw()


func _finish() -> void:
	_cooking = false
	_interactable.enabled = true
	queue_redraw()
	var not_stored: int = GameState.stash.add(recipe.result, recipe.result_count)
	if not_stored > 0:
		push_warning("Stash full: %d %s lost." % [not_stored, recipe.result.id])
	EventBus.toast_requested.emit(tr(&"TOAST_DISH_COOKED") % tr(recipe.result.name_key))
