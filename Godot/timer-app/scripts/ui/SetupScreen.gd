extends Control

signal start_pressed(duration_seconds: float, outro_enabled: bool)
signal open_theme_select_requested

const HOURS_MIN := 0
const HOURS_MAX := 24
const MINUTES_MIN := 0
const MINUTES_MAX := 59
const SECONDS_MIN := 0
const SECONDS_MAX := 59
const MIN_DURATION_SECONDS := 5.0
const MAX_DURATION_SECONDS := 24.0 * 3600.0
## Minimum timer length when outro is on (outro length; defined outside animation data).
const OUTRO_DURATION_SECONDS := 5.0

var _theme_controller: Node = null

@onready var hours_spinbox = $VBoxContainer/HBoxContainer/HoursSpinBox
@onready var minutes_spinbox = $VBoxContainer/HBoxContainer/MinutesSpinBox
@onready var seconds_spinbox = $VBoxContainer/HBoxContainer/SecondsSpinBox
@onready var outro_check = $VBoxContainer/OutroCheck
@onready var start_button = $VBoxContainer/StartButton
@onready var title_label = $VBoxContainer/TitleLabel
@onready var hours_label = $VBoxContainer/HBoxContainer/HoursLabel
@onready var minutes_label = $VBoxContainer/HBoxContainer/MinutesLabel
@onready var seconds_label = $VBoxContainer/HBoxContainer/SecondsLabel
@onready var animation_label = $VBoxContainer/AnimationThemeRow/AnimationLabel
@onready var animation_theme_label = $VBoxContainer/AnimationThemeRow/AnimationThemeLabel
@onready var change_theme_button = $VBoxContainer/AnimationThemeRow/ChangeThemeButton


func _ready() -> void:
	_apply_input_ranges()
	start_button.focus_mode = Control.FOCUS_NONE
	change_theme_button.focus_mode = Control.FOCUS_NONE
	change_theme_button.pressed.connect(_on_change_theme_pressed)
	hours_spinbox.get_line_edit().focus_exited.connect(_on_hours_focus_exited)
	minutes_spinbox.get_line_edit().focus_exited.connect(_on_minutes_focus_exited)
	seconds_spinbox.get_line_edit().focus_exited.connect(_on_seconds_focus_exited)
	start_button.pressed.connect(_on_start_pressed)
	if get_viewport():
		get_viewport().size_changed.connect(_apply_scaled_fonts)
	_apply_scaled_fonts()


func _on_hours_focus_exited() -> void:
	_read_and_clamp_spinbox(hours_spinbox, HOURS_MIN, HOURS_MAX)


func _on_minutes_focus_exited() -> void:
	_read_and_clamp_spinbox(minutes_spinbox, MINUTES_MIN, MINUTES_MAX)


func _on_seconds_focus_exited() -> void:
	_read_and_clamp_spinbox(seconds_spinbox, SECONDS_MIN, SECONDS_MAX)


func _apply_input_ranges() -> void:
	hours_spinbox.min_value = HOURS_MIN
	hours_spinbox.max_value = HOURS_MAX
	minutes_spinbox.min_value = MINUTES_MIN
	minutes_spinbox.max_value = MINUTES_MAX
	seconds_spinbox.min_value = SECONDS_MIN
	seconds_spinbox.max_value = SECONDS_MAX


func _read_and_clamp_spinbox(spinbox: SpinBox, min_val: float, max_val: float) -> float:
	var line_edit := spinbox.get_line_edit()
	return _parse_and_clamp_spinbox(spinbox, line_edit.text, min_val, max_val)


func _parse_and_clamp_spinbox(spinbox: SpinBox, text: String, min_val: float, max_val: float) -> float:
	var raw: float = text.to_float() if text.is_valid_float() else 0.0
	var clamped := clampf(raw, min_val, max_val)
	spinbox.value = clamped
	return clamped


func set_theme_controller(controller: Node) -> void:
	_theme_controller = controller
	_apply_scaled_fonts()


func set_animation_theme_display_name(display_name: String) -> void:
	animation_theme_label.text = display_name


func _on_change_theme_pressed() -> void:
	emit_signal("open_theme_select_requested")


func apply_scaled_fonts() -> void:
	_apply_scaled_fonts()


func _apply_scaled_fonts() -> void:
	if not _theme_controller or not is_instance_valid(get_parent()):
		return
	var safe_root := get_parent()
	if not safe_root.has_method("get_font_scale"):
		return
	var scale_factor: float = safe_root.get_font_scale()
	var base_title: int = _theme_controller.get_font_size("title") if _theme_controller.has_method("get_font_size") else 28
	var base_body: int = _theme_controller.get_font_size("body") if _theme_controller.has_method("get_font_size") else 18

	title_label.add_theme_font_size_override("font_size", int(base_title * scale_factor))
	animation_label.add_theme_font_size_override("font_size", int(base_body * scale_factor))
	animation_theme_label.add_theme_font_size_override("font_size", int(base_body * scale_factor))
	change_theme_button.add_theme_font_size_override("font_size", int(base_body * scale_factor))
	hours_label.add_theme_font_size_override("font_size", int(base_body * scale_factor))
	minutes_label.add_theme_font_size_override("font_size", int(base_body * scale_factor))
	seconds_label.add_theme_font_size_override("font_size", int(base_body * scale_factor))
	outro_check.add_theme_font_size_override("font_size", int(base_body * scale_factor))


func _on_start_pressed() -> void:
	hours_spinbox.apply()
	minutes_spinbox.apply()
	seconds_spinbox.apply()
	var hours: float = clampf(hours_spinbox.value, HOURS_MIN, HOURS_MAX)
	var minutes: float = clampf(minutes_spinbox.value, MINUTES_MIN, MINUTES_MAX)
	var seconds: float = clampf(seconds_spinbox.value, SECONDS_MIN, SECONDS_MAX)
	hours_spinbox.value = hours
	minutes_spinbox.value = minutes
	seconds_spinbox.value = seconds
	var outro_on: bool = outro_check.button_pressed
	var min_duration: float = OUTRO_DURATION_SECONDS if outro_on else MIN_DURATION_SECONDS
	if hours == 0.0 and minutes == 0.0 and seconds == 0.0:
		seconds = min_duration
		seconds_spinbox.value = min_duration
	var total: float = hours * 3600.0 + minutes * 60.0 + seconds
	var clamped := clampf(total, min_duration, MAX_DURATION_SECONDS)
	if outro_on and clamped < OUTRO_DURATION_SECONDS:
		clamped = OUTRO_DURATION_SECONDS
		seconds_spinbox.value = OUTRO_DURATION_SECONDS
		minutes_spinbox.value = 0.0
		hours_spinbox.value = 0.0
	emit_signal("start_pressed", clamped, outro_on)
