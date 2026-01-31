extends Control

## Debug overlay: open with 5 taps in the top-left corner.
## Provides "Return to setup" to leave the run screen when locked out.

signal return_to_setup_requested

const TAP_COUNT_TO_OPEN := 3
const TAP_WINDOW_SEC := 2.0

var _tap_count := 0

@onready var tap_trigger: Control = $TapTrigger
@onready var menu_panel: PanelContainer = $MenuPanel
@onready var return_button: Button = $MenuPanel/MarginContainer/VBox/ReturnToSetupButton
@onready var tap_timer: Timer = $TapTimer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_panel.visible = false
	tap_timer.one_shot = true
	tap_timer.timeout.connect(_on_tap_window_timeout)
	tap_trigger.gui_input.connect(_on_trigger_gui_input)
	return_button.pressed.connect(_on_return_pressed)


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
