extends Node

const ANIMATION_THEMES_PATH := "res://data/animation_themes.json"

var _animation_themes: Array = []
var _selected_theme_id: String = ""
## Optional theme injected at runtime (e.g. from debug menu). When enabled, included in theme selector and start flow.
var _injected_theme: Dictionary = {}
var _injected_theme_enabled: bool = false

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
	theme_select_screen.set_themes(_get_theme_list_for_selector())
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
	# Injected (debug) theme: optional signals; only connected if debug menu exposes them.
	if debug_menu.has_signal("injected_theme_enabled_changed"):
		debug_menu.injected_theme_enabled_changed.connect(_on_injected_theme_enabled_changed)
	if debug_menu.has_signal("injected_theme_data_changed"):
		debug_menu.injected_theme_data_changed.connect(_on_injected_theme_data_changed)
	if debug_menu.has_method("request_injected_theme_broadcast"):
		debug_menu.request_injected_theme_broadcast()

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


# ---- Injected (debug) theme support ----
# Optional theme supplied at runtime (e.g. debug menu). No file path; theme data set via ThemeController.set_theme_data.
# All callers use the same theme list and lookup; injected theme is merged in when enabled.

func set_injected_theme_enabled(enabled: bool) -> void:
	_injected_theme_enabled = enabled
	_refresh_theme_list_and_selection()


func set_injected_theme(data: Dictionary) -> void:
	_injected_theme = data
	_refresh_theme_list_and_selection()


func _get_theme_list_for_selector() -> Array:
	var list: Array = _animation_themes.duplicate()
	if _injected_theme_enabled and not _injected_theme.is_empty():
		list.append(_injected_theme)
	return list


func _refresh_theme_list_and_selection() -> void:
	theme_select_screen.set_themes(_get_theme_list_for_selector())
	var injected_id: String = _injected_theme.get("id", "")
	if _selected_theme_id == injected_id and not _injected_theme_enabled:
		_set_default_selected_theme()
		setup_screen.set_animation_theme_display_name(_get_selected_display_name())
	elif _injected_theme_enabled and _selected_theme_id.is_empty() and not _animation_themes.is_empty():
		setup_screen.set_animation_theme_display_name(_get_selected_display_name())


func _get_theme_by_id(theme_id: String) -> Dictionary:
	for t in _animation_themes:
		if t.get("id", "") == theme_id:
			return t
	if _injected_theme_enabled and _injected_theme.get("id", "") == theme_id:
		return _injected_theme
	return {}


func _theme_payload_from_dict(d: Dictionary) -> Dictionary:
	var payload: Dictionary = {}
	for key in ["idle", "events", "outro", "event_interval", "audio"]:
		if d.has(key):
			payload[key] = d[key]
	return payload


func _on_injected_theme_enabled_changed(enabled: bool) -> void:
	set_injected_theme_enabled(enabled)


func _on_injected_theme_data_changed(data: Dictionary) -> void:
	set_injected_theme(data)


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
	var scene_path: String = theme_dict.get("scene_path", "")
	if scene_path.is_empty():
		return

	var theme_path: String = theme_dict.get("theme_path", "")
	if theme_path.is_empty():
		# Injected theme: no file; set theme data from dict.
		theme_controller.set_theme_data(_theme_payload_from_dict(theme_dict))
	else:
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
