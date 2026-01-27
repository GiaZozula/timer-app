extends Control

signal start_pressed(duration_seconds: float)

@onready var minutes_spinbox = $VBoxContainer/HBoxContainer/MinutesSpinBox
@onready var start_button = $VBoxContainer/StartButton


func _ready():
	start_button.pressed.connect(_on_start_pressed)


func _on_start_pressed():
	var minutes = minutes_spinbox.value
	var duration_seconds = minutes * 60.0
	emit_signal("start_pressed", duration_seconds)
