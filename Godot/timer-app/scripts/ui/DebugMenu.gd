extends Control

## Debug overlay: open with 3 taps in the top-left corner.
## Provides "Return to setup" and optional injected (debug) theme. Debug-only; strip from production.
## Injected theme: these two signals are the only coupling to Main for the debug-theme feature.

signal return_to_setup_requested
signal injected_theme_enabled_changed(enabled: bool)
signal injected_theme_data_changed(data: Dictionary)

const TAP_COUNT_TO_OPEN := 3
const TAP_WINDOW_SEC := 2.0

var _tap_count := 0

@onready var tap_trigger: Control = $TapTrigger
@onready var menu_panel: PanelContainer = $MenuPanel
@onready var return_button: Button = $MenuPanel/MarginContainer/VBox/ReturnToSetupButton
@onready var tap_timer: Timer = $TapTimer
@onready var debug_theme_check: CheckButton = $MenuPanel/MarginContainer/VBox/DebugThemeCheck
@onready var reset_debug_theme_button: Button = $MenuPanel/MarginContainer/VBox/ResetDebugThemeButton


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_panel.visible = false
	tap_timer.one_shot = true
	tap_timer.timeout.connect(_on_tap_window_timeout)
	tap_trigger.gui_input.connect(_on_trigger_gui_input)
	return_button.pressed.connect(_on_return_pressed)
	debug_theme_check.button_pressed = true
	debug_theme_check.toggled.connect(_on_debug_theme_check_toggled)
	reset_debug_theme_button.pressed.connect(_on_reset_debug_theme_pressed)
	_emit_default_debug_theme()


func _on_trigger_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var ev := event as InputEventMouseButton
	if ev.button_index != MOUSE_BUTTON_LEFT or not ev.pressed:
		return

	_tap_count += 1
	if _tap_count >= TAP_COUNT_TO_OPEN:
		_tap_count = 0
		tap_timer.stop()
		menu_panel.visible = true
	else:
		if tap_timer.is_stopped():
			tap_timer.start(TAP_WINDOW_SEC)
		else:
			tap_timer.start(TAP_WINDOW_SEC)


func _on_tap_window_timeout() -> void:
	_tap_count = 0


func _on_return_pressed() -> void:
	menu_panel.visible = false
	emit_signal("return_to_setup_requested")


# ---- Injected (debug) theme: default data and signals to Main ----
func _get_default_debug_theme_data() -> Dictionary:
	return {
		"id": "debug",
		"display_name": "Debug (testing)",
		"scene_path": "res://scenes/animation/DebugThemeScene.tscn",
		"idle": "idle",
		"events": ["walk", "play"],
		"outro": "sleep",
		"event_interval": { "min": 8, "max": 14 },
		"audio": { "bg": "birds.ogg", "outro": "bell.ogg" }
	}


func _emit_default_debug_theme() -> void:
	injected_theme_enabled_changed.emit(debug_theme_check.button_pressed)
	injected_theme_data_changed.emit(_get_default_debug_theme_data())


## Call after Main has connected to signals to receive initial debug-theme state.
func request_injected_theme_broadcast() -> void:
	_emit_default_debug_theme()


func _on_debug_theme_check_toggled(toggled_on: bool) -> void:
	injected_theme_enabled_changed.emit(toggled_on)


func _on_reset_debug_theme_pressed() -> void:
	injected_theme_data_changed.emit(_get_default_debug_theme_data())
