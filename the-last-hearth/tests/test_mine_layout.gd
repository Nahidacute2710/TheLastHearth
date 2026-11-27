extends "res://tests/test_case.gd"


func test_doorway_passes_and_wall_blocks() -> void:
	await start_main()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	var body: CharacterBody2D = player()
	body.global_position = Vector2(370, 180)
	await hold(&"movement_right", 1.0)
	check(body.global_position.x > 420.0, "walks through the R1 -> R2 doorway (x=%.1f)" % body.global_position.x)
	body.global_position = Vector2(370, 120)
	await hold(&"movement_right", 1.0)
	check(body.global_position.x < 400.0, "wall between R1 and R2 blocks (x=%.1f)" % body.global_position.x)
