extends Control

var _theme_controller: Node = null
## Reference to the instanced scene's AnimationController; used to forward play_idle/event/outro from timer.
var _animation_controller: Node = null

@onready var time_label = $VBoxContainer/TimerStrip/CenterContainer/TimeLabel
@onready var timer_strip = $VBoxContainer/TimerStrip
## SubViewport where the selected animation scene (e.g. CatScene) is instanced.
@onready var viewport = $VBoxContainer/AnimationArea/SubViewport


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


func set_animation_scene(scene_path: String) -> void:
	for child in viewport.get_children():
		child.queue_free()
	_animation_controller = null

	var packed: PackedScene = load(scene_path) as PackedScene
	if not packed:
		return
	var instance: Node = packed.instantiate()
	viewport.add_child(instance)
	var ctrl = instance.get_node_or_null("AnimationController")
	if ctrl:
		_animation_controller = ctrl


func play_idle() -> void:
	if _animation_controller and _animation_controller.has_method("play_idle"):
		_animation_controller.play_idle()


func play_event() -> void:
	if _animation_controller and _animation_controller.has_method("play_event"):
		_animation_controller.play_event()


func play_outro() -> void:
	if _animation_controller and _animation_controller.has_method("play_outro"):
		_animation_controller.play_outro()


func update_time(remaining_seconds: float) -> void:
	var total_secs: int = int(remaining_seconds)
	var hours: int = int(total_secs / 3600.0)
	var minutes: int = int((total_secs % 3600) / 60.0)
	var secs: int = total_secs % 60
	time_label.text = "%d:%02d:%02d" % [hours, minutes, secs]
