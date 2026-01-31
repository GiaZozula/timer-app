extends Node

const ANIMATION_THEMES_PATH := "res://data/animation_themes.json"

var _animation_themes: Array = []
var _selected_theme_id: String = ""

@onready var timer_controller = $TimerController
@onready var theme_controller = $ThemeController
@onready var run_screen = $UI/SafeAreaRoot/RunScreen
@onready var setup_screen = $UI/SafeAreaRoot/SetupScreen
@onready var theme_select_screen = $UI/SafeAreaRoot/ThemeSelectScreen
@onready var debug_menu = $UI/DebugMenu


func _ready():
	_load_animation_themes()
	_set_default_selected_theme()

	setup_screen.set_theme_controller(theme_controller)
	setup_screen.apply_scaled_fonts()
	run_screen.set_theme_controller(theme_controller)
	run_screen.apply_scaled_fonts()
	theme_select_screen.set_theme_controller(theme_controller)
	theme_select_screen.set_themes(_animation_themes)
	theme_select_screen.apply_scaled_fonts()

	timer_controller.tick.connect(run_screen.update_time)
	timer_controller.event_trigger.connect(run_screen.play_event)
	timer_controller.outro_start.connect(run_screen.play_outro)
	timer_controller.finished.connect(_on_timer_finished)

	setup_screen.start_pressed.connect(_on_start_pressed)
	setup_screen.open_theme_select_requested.connect(_on_open_theme_select)
	theme_select_screen.theme_selected.connect(_on_theme_selected)
	theme_select_screen.back_requested.connect(_on_theme_select_back)
	debug_menu.return_to_setup_requested.connect(_on_debug_return_to_setup)

	run_screen.visible = false
	theme_select_screen.visible = false
	setup_screen.visible = true
	setup_screen.set_animation_theme_display_name(_get_selected_display_name())


func _load_animation_themes() -> void:
	if not FileAccess.file_exists(ANIMATION_THEMES_PATH):
		push_error("Animation themes file not found: %s" % ANIMATION_THEMES_PATH)
		return
	var file = FileAccess.open(ANIMATION_THEMES_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(content) != OK:
		push_error("Failed to parse animation themes JSON")
		return
	if not json.data is Array:
		push_error("Animation themes must be a JSON array")
		return
	_animation_themes = json.data


func _set_default_selected_theme() -> void:
	if _animation_themes.is_empty():
		_selected_theme_id = ""
		return
	var first: Dictionary = _animation_themes[0]
	_selected_theme_id = first.get("id", "")


func _get_theme_by_id(theme_id: String) -> Dictionary:
	for t in _animation_themes:
		if t.get("id", "") == theme_id:
			return t
	return {}


func _get_selected_display_name() -> String:
	var t = _get_theme_by_id(_selected_theme_id)
	return t.get("display_name", _selected_theme_id if _selected_theme_id else "—")


func _on_open_theme_select() -> void:
	setup_screen.visible = false
	theme_select_screen.visible = true


func _on_theme_selected(theme_id: String, display_name: String) -> void:
	_selected_theme_id = theme_id
	setup_screen.set_animation_theme_display_name(display_name)
	theme_select_screen.visible = false
	setup_screen.visible = true


func _on_theme_select_back() -> void:
	theme_select_screen.visible = false
	setup_screen.visible = true


func _on_start_pressed(duration_seconds: float, outro_enabled: bool) -> void:
	var theme_dict := _get_theme_by_id(_selected_theme_id)
	if theme_dict.is_empty():
		return
	var theme_path: String = theme_dict.get("theme_path", "")
	var scene_path: String = theme_dict.get("scene_path", "")
	if theme_path.is_empty() or scene_path.is_empty():
		return

	theme_controller.load_theme(theme_path)
	run_screen.set_animation_scene(scene_path)
	run_screen.play_idle()

	setup_screen.visible = false
	run_screen.visible = true
	timer_controller.start_timer(
		duration_seconds,
		theme_controller.get_event_interval_min(),
		theme_controller.get_event_interval_max(),
		outro_enabled
	)


func _on_timer_finished():
	print("Timer done")
	# Later: show celebration screen, play sound, etc.


func _on_debug_return_to_setup() -> void:
	timer_controller.stop_timer()
	run_screen.visible = false
	setup_screen.visible = true
