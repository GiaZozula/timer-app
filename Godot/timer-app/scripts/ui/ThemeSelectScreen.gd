extends Control

## Displays a list of available animation themes. Emits theme_selected when one is chosen,
## or back_requested when the user returns without changing selection.

signal theme_selected(theme_id: String, display_name: String)
signal back_requested

var _theme_controller: Node = null
var _themes: Array = []

@onready var title_label = $VBoxContainer/TitleLabel
@onready var list_container = $VBoxContainer/ScrollContainer/ThemeList
@onready var back_button = $VBoxContainer/BackButton


func _ready() -> void:
	back_button.focus_mode = Control.FOCUS_NONE
	back_button.pressed.connect(_on_back_pressed)
	if get_viewport():
		get_viewport().size_changed.connect(_apply_scaled_fonts)
	_apply_scaled_fonts()


func set_theme_controller(controller: Node) -> void:
	_theme_controller = controller
	_apply_scaled_fonts()


func set_themes(themes: Array) -> void:
	_themes = themes
	_build_list()


func _build_list() -> void:
	for child in list_container.get_children():
		child.queue_free()

	for theme_dict in _themes:
		if not theme_dict is Dictionary:
			continue
		var theme_id: String = theme_dict.get("id", "")
		var display_name: String = theme_dict.get("display_name", theme_id)
		if theme_id.is_empty():
			continue
		var btn := Button.new()
		btn.text = display_name
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_theme_pressed.bind(theme_id, display_name))
		list_container.add_child(btn)


func _on_theme_pressed(theme_id: String, display_name: String) -> void:
	emit_signal("theme_selected", theme_id, display_name)


func _on_back_pressed() -> void:
	emit_signal("back_requested")


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
	back_button.add_theme_font_size_override("font_size", int(base_body * scale_factor))
	for child in list_container.get_children():
		if child is Button:
			child.add_theme_font_size_override("font_size", int(base_body * scale_factor))
