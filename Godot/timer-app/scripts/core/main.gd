extends Node

@onready var timer_controller = $TimerController
@onready var theme_controller = $ThemeController
@onready var run_screen = $UI/SafeAreaRoot/RunScreen
@onready var setup_screen = $UI/SafeAreaRoot/SetupScreen
@onready var animation_controller = $AnimationRoot/CatScene/AnimationController


func _ready():
	theme_controller.load_theme("res://themes/cat_garden.theme.json")

	setup_screen.set_theme_controller(theme_controller)
	setup_screen.apply_scaled_fonts()
	run_screen.set_theme_controller(theme_controller)
	run_screen.apply_scaled_fonts()

	timer_controller.tick.connect(run_screen.update_time)
	timer_controller.event_trigger.connect(animation_controller.play_event)
	timer_controller.outro_start.connect(animation_controller.play_outro)
	timer_controller.finished.connect(_on_timer_finished)

	setup_screen.start_pressed.connect(_on_start_pressed)

	run_screen.visible = false
	setup_screen.visible = true


func _on_start_pressed(duration_seconds: float):
	setup_screen.visible = false
	run_screen.visible = true

	timer_controller.start_timer(
		duration_seconds,
		theme_controller.get_event_interval_min(),
		theme_controller.get_event_interval_max()
	)


func _on_timer_finished():
	print("Timer done")
	# Later: show celebration screen, play sound, etc.
