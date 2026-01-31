extends Node

signal tick(remaining_time)
signal event_trigger
signal outro_start
signal finished

## Outro length (last N seconds of timer). Defined outside animation data.
const OUTRO_DURATION := 5.0
## At this many seconds left we stop scheduling events so we can transition to idle before outro.
const IDLE_PADDING_BEFORE_OUTRO := 10.0

var total_duration := 0.0
var start_time_ms := 0
var running := false
var outro_enabled := true

var event_min_sec := 0.0
var event_max_sec := 0.0
var next_event_time := 0.0
var outro_started := false


func start_timer(duration_seconds: float, event_min: float, event_max: float, with_outro: bool = true) -> void:
	total_duration = duration_seconds
	start_time_ms = Time.get_ticks_msec()
	running = true
	outro_started = false
	outro_enabled = with_outro
	event_min_sec = event_min
	event_max_sec = event_max

	_schedule_next_event_if_allowed()


func stop_timer() -> void:
	running = false


func _process(_delta: float) -> void:
	if not running:
		return

	var now_ms := Time.get_ticks_msec()
	var elapsed := (now_ms - start_time_ms) / 1000.0
	var remaining := maxf(total_duration - elapsed, 0.0)

	emit_signal("tick", remaining)

	if outro_enabled:
		if not outro_started and remaining <= OUTRO_DURATION:
			outro_started = true
			emit_signal("outro_start")
		var in_padding := remaining <= IDLE_PADDING_BEFORE_OUTRO
		if not in_padding and elapsed >= next_event_time:
			emit_signal("event_trigger")
			_schedule_next_event_if_allowed()
	else:
		if elapsed >= next_event_time:
			emit_signal("event_trigger")
			_schedule_next_event()

	if remaining <= 0.0:
		running = false
		emit_signal("finished")


func _schedule_next_event_if_allowed() -> void:
	var elapsed := (Time.get_ticks_msec() - start_time_ms) / 1000.0
	var remaining := maxf(total_duration - elapsed, 0.0)
	if not outro_enabled or remaining > IDLE_PADDING_BEFORE_OUTRO:
		_schedule_next_event()


func _schedule_next_event() -> void:
	var delay := randf_range(event_min_sec, event_max_sec)
	var elapsed := (Time.get_ticks_msec() - start_time_ms) / 1000.0
	next_event_time = elapsed + delay
