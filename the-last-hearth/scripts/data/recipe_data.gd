class_name RecipeData
extends Resource
## A dish: ingredients taken from the tavern stash, result put back into the stash. Instances in data/recipes/.

@export var id: StringName = &""
@export var ingredients: Array[RecipeIngredient] = []
@export var result: ItemData
@export var result_count: int = 1
## Seconds to cook.
@export var cook_time: float = 1.5


func can_cook(from: Inventory) -> bool:
	for ingredient: RecipeIngredient in ingredients:
		if from.count_of(ingredient.item) < ingredient.count:
			return false
	return true


## Removes the ingredients. Returns false (and removes nothing) when something is missing.
func take_ingredients(from: Inventory) -> bool:
	if not can_cook(from):
		return false
	for ingredient: RecipeIngredient in ingredients:
		from.remove(ingredient.item, ingredient.count)
	return true
