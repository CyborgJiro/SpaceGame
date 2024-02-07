extends "res://addons/gdquest_practice_framework/tester/test.gd"

var speed_after_boost_start := 0.0
var is_timer_started_on_boost := false
var is_on_timer_timeout_defined := false
var is_timer_connected_to_on_timer_timeout := false
var speed_after_boost_end := 0.0


func _setup_state() -> void:
	if _practice.max_speed > 0.0:
		_solution.max_speed = _practice.max_speed


func _setup_populate_test_space() -> void:
	# Test the scene and gather information
	# First with the timer node
	var timer: Timer = _practice.get_node("Timer")
	if timer != null:
		is_on_timer_timeout_defined = _practice.has_method("_on_timer_timeout")
		if is_on_timer_timeout_defined:
			is_timer_connected_to_on_timer_timeout = timer.timeout.is_connected(_practice._on_timer_timeout)
			timer.timeout.connect(func store_speed_after_timeout() -> void:
				await get_tree().process_frame
				speed_after_boost_end = _practice.max_speed
			)

	# Boost the ship, then move in a "circle"
	Input.action_press("boost")
	await get_tree().process_frame
	speed_after_boost_start = _practice.max_speed
	if timer != null:
		is_timer_started_on_boost = not timer.is_stopped()
	Input.action_release("boost")

	var inputs_to_test := [
		["move_right"],
		["move_right", "move_up"],
		["move_up"],
		["move_left", "move_up"],
		["move_left"],
		["move_left", "move_down"],
		["move_down"],
		["move_right", "move_down"],
	]
	for action_list in inputs_to_test:
		for action in action_list:
			Input.action_press(action)
		await get_tree().create_timer(0.3).timeout
		for action in action_list:
			Input.action_release(action)


func _test_pressing_the_boost_input_increases_max_speed() -> String:
	if is_equal_approx(speed_after_boost_start, _practice.normal_speed):
		return tr("It appears that the ship's speed was still equal to normal_speed after pressing the boost input. Did you forget to increase the ship's speed? It should be set to `boost_speed`.")
	elif speed_after_boost_start != _practice.boost_speed:
		return tr("It appears that the ship's speed was not equal to boost_speed after pressing the boost input. Did you forget to increase the ship's speed? It should be set to `boost_speed`.")
	return ''


func _test_boost_input_starts_timer() -> String:
	if not is_timer_started_on_boost:
		return tr("The Timer node is not started when the boost input is pressed. Did you forget to start it?")
	return ''


func _test_timer_timeout_signal_is_connected() -> String:
	if not is_timer_connected_to_on_timer_timeout:
		return tr("The Timer node's timeout signal is not connected to the `_on_timer_timeout()` function. Did you forget to connect it?")
	return ''


func _test_timer_timeout_restores_normal_speed() -> String:
	if is_equal_approx(speed_after_boost_end, _practice.boost_speed):
		return tr("The ship's speed was still equal to boost_speed after the timer timed out. Did you forget to restore the ship's speed? It should be set to `normal_speed`.")
	elif speed_after_boost_end != _practice.normal_speed:
		return tr("It appears that the ship's speed was not equal to normal_speed after the timer timed out. Did you forget to restore the ship's speed? It should be set to `normal_speed`.")
	return ''
