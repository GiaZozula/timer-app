extends Node

signal tick(remaining_time)
signal event_trigger
signal outro_start
signal finished

@export var outro_duration := 10.0  # seconds before end when outro starts

var total_duration := 0.0
var start_time_ms := 0
var running := false

var next_event_time := 0.0
var outro_started := false


func start_timer(duration_seconds: float, event_min: float, event_max: float):
	total_duration = duration_seconds
	start_time_ms = Time.get_ticks_msec()
	running = true
	outro_started = false

	_schedule_next_event(event_min, event_max)


func stop_timer():
	running = false


func _process(_delta):
	if not running:
		return

	var now_ms = Time.get_ticks_msec()
	var elapsed = (now_ms - start_time_ms) / 1000.0
	var remaining = max(total_duration - elapsed, 0)

	emit_signal("tick", remaining)

	# trigger outro
	if not outro_started and remaining <= outro_duration:
		outro_started = true
		emit_signal("outro_start")

	# trigger random event
	if elapsed >= next_event_time and remaining > outro_duration:
		emit_signal("event_trigger")

	# finished
	if remaining <= 0:
		running = false
		emit_signal("finished")


func _schedule_next_event(min_sec: float, max_sec: float):
	var delay = randf_range(min_sec, max_sec)
	var elapsed = (Time.get_ticks_msec() - start_time_ms) / 1000.0
	next_event_time = elapsed + delay
