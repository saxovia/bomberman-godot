extends StaticBody2D

var time: float = 4
var active_player : Node
@onready var timer = $Timer
@onready var endtimer = $EndTimer
@onready var despawn_timer = $DespawnTimer
@export var picked_up_by_player = false


func _on_area_2d_body_entered(body):
	if body.is_in_group("players") and body.ghost_active == false and body.invincible_active == false:
		active_player = body
		if active_player.numOfExtenders < 1:
			if not picked_up_by_player:
				get_parent().visible = false
			picked_up_by_player = true
			get_parent().kms = true
			active_player.numOfExtenders += 1
			$GetPowerUpStreamPlayer.play()

