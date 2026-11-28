extends Logger
## Counts engine and script errors (not warnings) so the test runner can fail a test that hit one.
## Without this, a SCRIPT ERROR inside a test stops that test function silently and it would PASS.

var error_count: int = 0
var last_errors: PackedStringArray = []
var _mutex: Mutex = Mutex.new()


func _log_error(function: String, file: String, line: int, code: String, rationale: String,
		_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
	if error_type == ERROR_TYPE_WARNING:
		return
	_mutex.lock()
	error_count += 1
	last_errors.append("%s (%s:%d %s)" % [rationale if rationale != "" else code, file.get_file(), line, function])
	_mutex.unlock()


func take_errors() -> PackedStringArray:
	_mutex.lock()
	var errors: PackedStringArray = last_errors
	last_errors = []
	_mutex.unlock()
	return errors
