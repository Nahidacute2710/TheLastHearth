extends "res://tests/test_case.gd"

const HATCH_POS: Vector2 = Vector2(688, 418)
const HALL_CENTER: Vector2 = Vector2(384, 240)


func test_prompt_shows_near_hatch_and_hides_away() -> void:
	await start_main()
	var prompt: Label = main.find_child("InteractionPrompt", true, false) as Label
	check(prompt != null, "prompt exists")
	check(not prompt.visible, "prompt hidden at start")
	player().global_position = HATCH_POS
	await wait_physics(5)
	await tree.process_frame
	check(prompt.visible, "prompt visible near hatch")
	check_eq(prompt.text, "[E] Go down to the mine", "prompt text")
	player().global_position = HALL_CENTER
	await wait_physics(5)
	await tree.process_frame
	check(not prompt.visible, "prompt hidden away from hatch")
