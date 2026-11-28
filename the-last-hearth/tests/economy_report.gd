extends SceneTree
## Prints the Hearth Flame pacing for every EconomySim profile (copy into docs/ECONOMY_BALANCING.md).
## godot --headless --path . -s res://tests/economy_report.gd


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	# Loaded at run time: the autoloads the game scripts use exist only once the tree runs.
	var sim_script: GDScript = load("res://scripts/debug/economy_sim.gd")
	var sim: RefCounted = sim_script.new()
	print("payment %d, %d mushrooms per stew, %d pre-placed mushrooms, %d miners (%.2f mushroom each), %.1f veins x %.1f coal" % [
		sim.get("payment"), sim.get("mushrooms_per_stew"), sim.get("preplaced_mushrooms"), sim.get("miners"), sim.get("miner_mushroom_drop"), sim.get("avg_veins"), sim.get("avg_coal_per_vein")])
	var profiles: Dictionary = sim_script.get("PROFILES")
	for name: StringName in profiles:
		var profile: Dictionary = profiles[name]
		var per_run: Dictionary = sim.call("run_yield", profile)
		var result: Dictionary = sim.call("simulate", profile)
		var level_day: Dictionary = result["level_day"]
		print("%s: %.2f mushrooms + %.2f coal per run; level day: 2=%s 3=%s 4=%s 5=%s" % [name, per_run["mushrooms"], per_run["coal"],
			level_day.get(2, "-"), level_day.get(3, "-"), level_day.get(4, "-"), level_day.get(5, "-")])
		for row: Dictionary in result["days"]:
			print("  day %2d  earned %5.1f  gold %6.1f  coal %5.1f  level %d" % [row["day"], row["earned"], row["gold"], row["coal"], row["level"]])
	quit()
