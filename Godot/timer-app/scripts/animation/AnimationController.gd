extends Node

enum State { IDLE, EVENT, OUTRO }

var state := State.IDLE

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var theme_controller: Node = get_node("/root/Main/ThemeController")


func _ready():
	animation_player.animation_finished.connect(_on_animation_finished)


func play_idle():
	state = State.IDLE
	var anim_name = theme_controller.get_idle_animation()
	if anim_name != "":
		animation_player.play(anim_name)


func play_event():
	if state != State.IDLE:
		return

	state = State.EVENT
	var anim_name = theme_controller.get_random_event_animation()
	if anim_name != "":
		animation_player.play(anim_name)


func play_outro():
	state = State.OUTRO
	var anim_name = theme_controller.get_outro_animation()
	if anim_name != "":
		animation_player.play(anim_name)


func _on_animation_finished(_anim_name: String):
	if state == State.EVENT:
		play_idle()
	elif state == State.OUTRO:
		# stay in final pose or loop idle if you want
		pass
