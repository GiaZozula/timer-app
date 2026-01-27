extends Control

@onready var time_label = $CenterContainer/TimeLabel


func update_time(remaining_seconds: float):
	var seconds = int(remaining_seconds)
	var minutes = int(seconds / 60.0)
	var secs = seconds % 60

	time_label.text = "%02d:%02d" % [minutes, secs]
