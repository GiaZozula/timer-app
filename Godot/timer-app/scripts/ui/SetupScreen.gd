extends Control

signal start_pressed(duration_seconds: float)

var _theme_controller: Node = null

@onready var minutes_spinbox = $VBoxContainer/HBoxContainer/MinutesSpinBox
@onready var start_button = $VBoxContainer/StartButton
@onready var title_label = $VBoxContainer/TitleLabel
@onready var minutes_label = $VBoxContainer/HBoxContainer/MinutesLabel


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	if get_viewport():
		get_viewport().size_changed.connect(_apply_scaled_fonts)
	_apply_scaled_fonts()


func set_theme_controller(controller: Node) -> void:
	_theme_controller = controller
	_apply_scaled_fonts()


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
	minutes_label.add_theme_font_size_override("font_size", int(base_body * scale_factor))


func _on_start_pressed() -> void:
	var minutes: float = minutes_spinbox.value
	emit_signal("start_pressed", minutes * 60.0)
