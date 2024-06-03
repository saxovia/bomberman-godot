extends StaticBody2D
class_name Waves
@onready var animation_player = $AnimationPlayer
@export var groupName = "Waves"
@export var deadly = true
@onready var timer = $Timer

func _ready():
	timer.start()
	animation_player.play("move")
	await animation_player.animation_finished


func _on_timer_timeout():
	deadly = false


