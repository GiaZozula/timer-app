extends Control

var _theme_controller: Node = null

@onready var time_label = $VBoxContainer/TimerStrip/CenterContainer/TimeLabel
@onready var timer_strip = $VBoxContainer/TimerStrip


func _ready() -> void:
	if get_viewport():
		get_viewport().size_changed.connect(_apply_scaled_fonts)
	_apply_scaled_fonts()


func set_theme_controller(controller: Node) -> void:
	_theme_controller = controller
	_apply_scaled_fonts()


func apply_scaled_fonts() -> void:
	_apply_scaled_fonts()


func _apply_scaled_fonts() -> void:
	if not is_instance_valid(get_parent()):
		return
	var safe_root := get_parent()
	if not safe_root.has_method("get_font_scale"):
		return
	var scale_factor: float = safe_root.get_font_scale()
	var base_timer := 96
	if _theme_controller and _theme_controller.has_method("get_font_size"):
		base_timer = _theme_controller.get_font_size("timer")
	var font_size := int(base_timer * scale_factor)
	time_label.add_theme_font_size_override("font_size", font_size)
	timer_strip.custom_minimum_size.y = int(font_size * 1.6)


func update_time(remaining_seconds: float) -> void:
	var seconds: int = int(remaining_seconds)
	var minutes: int = int(seconds / 60.0)
	var secs: int = seconds % 60
	time_label.text = "%02d:%02d" % [minutes, secs]
