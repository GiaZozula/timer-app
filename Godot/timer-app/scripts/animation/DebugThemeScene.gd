extends Control

## Debug-only animation scene: shows state (idle/event/outro), embedding bounds, and user-chosen info.
## Injected via debug menu only. Pulls display info from Main (get_display_info_for_animation) in _ready().

@onready var state_display: ColorRect = $StateDisplay
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bounds_label: Label = $InfoOverlay/MarginContainer/VBoxContainer/BoundsLabel
@onready var state_label: Label = $InfoOverlay/MarginContainer/VBoxContainer/StateLabel
@onready var info_label: Label = $InfoOverlay/MarginContainer/VBoxContainer/InfoLabel

const STATE_COLORS := {
	"idle": Color(0.5, 0.5, 0.5),
	"walk": Color(0.9, 0.85, 0.2),
	"play": Color(0.2, 0.75, 0.35),
	"sleep": Color(0.25, 0.4, 0.85)
}


func _ready() -> void:
	_build_state_animations()
	_update_size_from_viewport()
	if get_viewport():
		get_viewport().size_changed.connect(_update_size_from_viewport)
	animation_player.current_animation_changed.connect(_on_current_animation_changed)
	state_label.text = "State: IDLE"
	_refresh_display_info_from_main()
	queue_redraw()


func _update_size_from_viewport() -> void:
	var viewport_inst := get_viewport()
	if not viewport_inst:
		return
	var viewport_size := viewport_inst.get_visible_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		return
	set_size(viewport_size)
	state_display.set_size(viewport_size)
	state_display.set_position(Vector2.ZERO)
	_update_bounds_text(int(viewport_size.x), int(viewport_size.y))
	queue_redraw()


func _build_state_animations() -> void:
	var library := AnimationLibrary.new()
	for state_name in STATE_COLORS:
		var anim := Animation.new()
		var track_idx := anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track_idx, NodePath("StateDisplay:color"))
		anim.track_insert_key(track_idx, 0.0, STATE_COLORS[state_name])
		anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_LINEAR)
		if state_name == "idle":
			anim.length = 1.0
			anim.loop_mode = Animation.LOOP_LINEAR
		else:
			anim.length = 5.0
		library.add_animation(state_name, anim)
	animation_player.add_animation_library("", library)


func _update_bounds_text(w: int, h: int) -> void:
	bounds_label.text = "Bounds: %d × %d" % [w, h]


func _on_current_animation_changed(anim_name: String) -> void:
	# Strip library prefix if present (e.g. "library/idle" -> "idle").
	var name_only := anim_name.get_file() if anim_name.contains("/") else anim_name
	if name_only.is_empty():
		return
	if name_only == "idle":
		state_label.text = "State: IDLE"
	elif name_only in ["walk", "play"]:
		state_label.text = "State: EVENT (%s)" % name_only
	elif name_only == "sleep":
		state_label.text = "State: OUTRO (%s)" % name_only
	else:
		state_label.text = "State: %s" % name_only


func _draw() -> void:
	var rect_size := get_size()
	if rect_size.x <= 0 or rect_size.y <= 0:
		return
	var border := Rect2(1, 1, rect_size.x - 2, rect_size.y - 2)
	draw_rect(border, Color(0.2, 0.2, 0.2, 0.9), false, 3.0)


func _refresh_display_info_from_main() -> void:
	var main := get_node_or_null("/root/Main")
	if main and main.has_method("get_display_info_for_animation"):
		set_display_info(main.get_display_info_for_animation())


## Expects duration_seconds, outro_enabled, outro_duration_seconds, event_interval_min, event_interval_max.
func set_display_info(info: Dictionary) -> void:
	var parts: PackedStringArray = []
	var duration: float = info.get("duration_seconds", 0.0)
	var hours := int(duration / 3600.0)
	var mins := int(fmod(duration / 60.0, 60.0))
	var secs := int(fmod(duration, 60.0))
	parts.append("Duration: %d:%02d:%02d" % [hours, mins, secs])
	if info.get("outro_enabled", false):
		parts.append("Outro: on (last %s s)" % str(info.get("outro_duration_seconds", 0)))
	else:
		parts.append("Outro: off")
	var ev_min: float = info.get("event_interval_min", 0.0)
	var ev_max: float = info.get("event_interval_max", 0.0)
	parts.append("Event interval: %.1f–%.1f s" % [ev_min, ev_max])
	info_label.text = "\n".join(parts)
