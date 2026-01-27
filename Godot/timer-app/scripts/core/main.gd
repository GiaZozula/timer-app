extends Node

@onready var timer_controller = $TimerController
@onready var theme_controller = $ThemeController
@onready var run_screen = $UI/RunScreen
@onready var setup_screen = $UI/SetupScreen
@onready var animation_controller = $AnimationRoot/CatScene/AnimationController


func _ready():
	# Load theme
	theme_controller.load_theme("res://themes/cat_garden.theme.json")

	# Connect timer signals
	timer_controller.tick.connect(run_screen.update_time)
	timer_controller.event_trigger.connect(animation_controller.play_event)
	timer_controller.outro_start.connect(animation_controller.play_outro)
	timer_controller.finished.connect(_on_timer_finished)

	# Connect UI
	setup_screen.start_pressed.connect(_on_start_pressed)

	# Initial UI state
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
