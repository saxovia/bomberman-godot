extends StaticBody2D

var time: float = 4
var end_time : float = 3
var flicker_time : float = 0.255
var active = true
var active_player : Node
var playerowner = null
var picked_up_by_player = false
@onready var timer = $Timer
@onready var endtimer = $EndTimer

func _on_area_2d_body_entered(body):
	if body.is_in_group("players") and body.ghost_active == false and body.invincible_active == false and active == true:
		active = false
		if picked_up_by_player == false:
			get_parent().visible = false
		picked_up_by_player = true
		active_player = body
		active_player.ghost_active = true
		active_player.activate_ghost(active_player)
		timer.start(time)

func _on_timer_timeout():
	endtimer.start(end_time)
	$FlickerTimer2.start(flicker_time)

func _on_end_timer_timeout():
	$FlickerTimer.stop()
	$FlickerTimer2.stop()
	active_player.ghost_active = false
	active_player.deactivate_ghost(active_player)
	get_parent().kms = true
	queue_free()


func _on_flicker_time_timeout():
	active_player.get_node("AnimatedSprite2D").self_modulate = Color('#ADD8E6')
	$FlickerTimer2.start(flicker_time)

func _on_flicker_timer_2_timeout():
	active_player.get_node("AnimatedSprite2D").self_modulate = Color('#ffe9ec')
	$FlickerTimer.start(flicker_time)
