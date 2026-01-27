extends Node

func _ready():
	$UI/SetupScreen.start_timer.connect(_on_start_timer)


func _on_start_timer(duration):
	print("Timer requested:", duration)
