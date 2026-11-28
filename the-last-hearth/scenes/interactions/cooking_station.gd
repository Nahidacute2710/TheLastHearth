extends Node2D
## Stove in the tavern. Interacting cooks the recipe from the tavern stash; the dish goes back into the stash.
## Shows a placeholder progress bar while cooking. Leaving the tavern mid-cook finishes the dish at once.
## Does not start when the stash has no room for the dish.

const BAR_SIZE: Vector2 = Vector2(24.0, 3.0)
const BAR_OFFSET: Vector2 = Vector2(-12.0, -38.0)
const BAR_BACK: Color = Color(0.0862745, 0.0784314, 0.109804)
const BAR_FILL: Color = Color(0.95, 0.69, 0.29)

@export var recipe: RecipeData

var _time_left: float = 0.0
var _cook_time: float = 1.0
var _cooking: bool = false
## Dishes in the pot (Hearth Flame level 2 cooks up to 2 per batch).
var _batch: int = 0

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
		_finish(false)


func is_cooking() -> bool:
	return _cooking


## 0..1 while cooking.
func get_progress() -> float:
	return 1.0 - _time_left / _cook_time if _cooking else 0.0


## Dishes the stove would cook now: up to the Hearth Flame batch size, limited by ingredients
## and stash space. At least 1 when anything can be cooked.
func get_batch_size() -> int:
	var batch: int = 0
	var limit: int = GameState.get_cook_batch_size()
	while batch < limit and _has_ingredients_for(batch + 1) \
			and GameState.stash.can_add(recipe.result, recipe.result_count * (batch + 1)):
		batch += 1
	return batch


func _has_ingredients_for(batches: int) -> bool:
	for ingredient: RecipeIngredient in recipe.ingredients:
		if GameState.stash.count_of(ingredient.item) < ingredient.count * batches:
			return false
	return true


func _draw() -> void:
	if not _cooking:
		return
	draw_rect(Rect2(BAR_OFFSET, BAR_SIZE).grow(1.0), BAR_BACK)
	draw_rect(Rect2(BAR_OFFSET, Vector2(BAR_SIZE.x * get_progress(), BAR_SIZE.y)), BAR_FILL)


func _on_interacted(_actor: Node2D) -> void:
	if _cooking or recipe == null:
		return
	if not GameState.stash.can_add(recipe.result, recipe.result_count):
		EventBus.toast_requested.emit(tr(&"TOAST_STASH_FULL"))
		return
	if not recipe.can_cook(GameState.stash):
		var first: RecipeIngredient = recipe.ingredients[0]
		EventBus.toast_requested.emit(tr(&"TOAST_MISSING_INGREDIENTS") % [first.count, tr(first.item.name_key)])
		return
	_batch = maxi(get_batch_size(), 1)
	for i: int in _batch:
		recipe.take_ingredients(GameState.stash)
	_cooking = true
	_cook_time = recipe.cook_time * GameState.get_cook_time_factor()
	_time_left = _cook_time
	_interactable.enabled = false
	queue_redraw()


## `announce` is false when the tavern is being unloaded (no toast or sound then).
func _finish(announce: bool = true) -> void:
	_cooking = false
	_interactable.enabled = true
	queue_redraw()
	# Space was checked before cooking; if something else filled the stash meanwhile, the dish
	# still goes in (over the slot limit) so it is never lost.
	var made: int = recipe.result_count * _batch
	GameState.stash.add_ignoring_limit(recipe.result, made)
	_batch = 0
	if announce:
		if made > 1:
			EventBus.toast_requested.emit(tr(&"TOAST_DISHES_COOKED") % [made, tr(recipe.result.name_key)])
		else:
			EventBus.toast_requested.emit(tr(&"TOAST_DISH_COOKED") % tr(recipe.result.name_key))
		EventBus.sfx_requested.emit(&"cook_done")
