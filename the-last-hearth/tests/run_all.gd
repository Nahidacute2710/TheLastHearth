extends SceneTree
## Headless test runner (no addons).
## Usage (from the-last-hearth/): godot --headless --path . -s res://tests/run_all.gd
## Runs every res://tests/test_*.gd. Each test file extends res://tests/test_case.gd and
## defines methods named test_*. Exit code is 1 when any test fails.
## A test also fails when it logs an engine or script error (a SCRIPT ERROR would otherwise
## stop the test function silently and count as a pass).

const TESTS_DIR: String = "res://tests/"
const ErrorCounter: GDScript = preload("res://tests/error_counter.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var errors: Logger = ErrorCounter.new() as Logger
	OS.add_logger(errors)
	var files: PackedStringArray = []
	for file_name: String in DirAccess.get_files_at(TESTS_DIR):
		if file_name.begins_with("test_") and file_name.ends_with(".gd"):
			files.append(file_name)
	files.sort()
	var passed: int = 0
	var failed: int = 0
	for file_name: String in files:
		var script: GDScript = load(TESTS_DIR + file_name) as GDScript
		if script == null:
			print("FAIL %s: could not load" % file_name)
			failed += 1
			continue
		for method: Dictionary in script.get_script_method_list():
			var method_name: String = method["name"]
			if not method_name.begins_with("test_"):
				continue
			var test_case: Object = script.new()
			test_case.set("tree", self)
			await test_case.call("before_each")
			await test_case.call(method_name)
			await test_case.call("after_each")
			var failures: Array[String] = test_case.get("failures")
			for logged: String in errors.call("take_errors"):
				failures.append("error logged: " + logged)
			if failures.is_empty():
				passed += 1
				print("PASS %s::%s" % [file_name, method_name])
			else:
				failed += 1
				print("FAIL %s::%s" % [file_name, method_name])
				for message: String in failures:
					print("	- " + message)
	OS.remove_logger(errors)
	print("Tests: %d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)
