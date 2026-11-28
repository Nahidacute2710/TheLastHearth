extends "res://tests/test_case.gd"
## VS-E1: Hearth Flame pacing with the real data (EconomySim). Target for normal play:
## level 2 around day 2–3, level 3 around day 5, level 4 around day 8, level 5 around day 12.

const TARGETS: Dictionary[int, Vector2i] = {2: Vector2i(2, 3), 3: Vector2i(4, 6), 4: Vector2i(7, 9), 5: Vector2i(11, 13)}


func test_normal_play_hits_the_target_days() -> void:
	var sim: EconomySim = EconomySim.new()
	check_eq(sim.preplaced_mushrooms, 4, "sim reads the 4 pre-placed mushrooms")
	check_eq(sim.miners, 10, "sim reads the 10 miners")
	var level_day: Dictionary = sim.simulate(EconomySim.PROFILES[&"normal"])["level_day"]
	for level: int in TARGETS:
		var day: int = level_day.get(level, 999)
		var target: Vector2i = TARGETS[level]
		check(day >= target.x and day <= target.y, "level %d on day %d (target %d–%d)" % [level, day, target.x, target.y])


func test_skilled_is_faster_and_slow_is_slower_but_finishes() -> void:
	var sim: EconomySim = EconomySim.new()
	var normal: Dictionary = sim.simulate(EconomySim.PROFILES[&"normal"])["level_day"]
	var skilled: Dictionary = sim.simulate(EconomySim.PROFILES[&"skilled"])["level_day"]
	var slow: Dictionary = sim.simulate(EconomySim.PROFILES[&"slow"])["level_day"]
	check(int(skilled.get(5, 999)) <= int(normal.get(5, 999)), "skilled reaches level 5 no later")
	check(int(slow.get(5, 999)) >= int(normal.get(5, 999)), "slow reaches level 5 no earlier")
	check(int(slow.get(5, 999)) <= 20, "slow play still reaches level 5 within 20 days (day %s)" % slow.get(5, "-"))


func test_mushrooms_cover_two_customers_and_a_meal() -> void:
	var sim: EconomySim = EconomySim.new()
	var per_run: Dictionary = sim.run_yield(EconomySim.PROFILES[&"normal"])
	var stews: float = float(per_run["mushrooms"]) / sim.mushrooms_per_stew
	check(stews >= 3.0, "normal run gives enough for 2 travelers + 1 meal (%.2f stews)" % stews)
