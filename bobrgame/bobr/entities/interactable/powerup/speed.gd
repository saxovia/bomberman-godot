extends StaticBody2D

var time: float = 6
var active = true
var active_player : Node

@onready var timer = $Timer
@export var picked_up_by_player = false

func _on_area_2d_body_entered(body):
	if body.is_in_group("players") and body.speed_active == false and active == true:
		active = false
		visible = false
		if not picked_up_by_player:
			get_parent().visible = false
		picked_up_by_player = true
		active_player = body
		active_player.speed_active = true
		active_player.move_speed *= 1.5
		timer.start(time)
		$GetPowerUpStreamPlayer.play()


func _on_timer_timeout():
	if active_player.speed_active:
		active_player.speed_active = false
		active_player.move_speed /= 1.5
