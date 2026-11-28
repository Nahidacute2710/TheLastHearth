extends "res://tests/test_case.gd"
## VSA5 / TECH-008: physics interpolation is on, and moving bodies take part in it.
## Teleports (spawn markers, enemy placement) call reset_physics_interpolation(); the camera-jitter
## check on a 120/144 Hz screen is a manual playtest step.


func test_physics_interpolation_is_enabled() -> void:
	check(ProjectSettings.get_setting("physics/common/physics_interpolation"), "project setting is on")
	check_eq(Engine.physics_ticks_per_second, 60, "physics still runs at 60 ticks per second")


func test_player_and_enemies_are_interpolated() -> void:
	await start_main()
	check(player().is_physics_interpolated(), "player is interpolated")
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	check(player().is_physics_interpolated(), "player in the mine is interpolated")
	var miner: Node2D = level().find_child("Miner*", true, false) as Node2D
	check(miner != null and miner.is_physics_interpolated(), "miners are interpolated")
	var camera: Camera2D = player().get_node("%Camera") as Camera2D
	check(camera.is_physics_interpolated(), "camera follows the interpolated player")
	check_eq(camera.process_callback, Camera2D.CAMERA2D_PROCESS_PHYSICS, "camera updates in physics, as interpolation needs")


func test_spawn_places_the_player_on_the_marker() -> void:
	await start_main()
	router().call("go_to", &"dungeon", &"entrance")
	await wait(0.8)
	var marker: Node2D = level().find_child("entrance", true, false) as Node2D
	check(marker != null, "entrance marker exists")
	if marker != null:
		check(player().global_position.distance_to(marker.global_position) < 4.0, "player stands on the entrance marker")
