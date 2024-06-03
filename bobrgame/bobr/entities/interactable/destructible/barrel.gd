extends StaticBody2D

var bombinstance = preload("res://entities/interactable/collectible/bomb_pickupable.tscn")
@export var destroyed = false

func _on_area_2d_area_entered(area):
	if area.name == "PlayerCollisionArea":
		$AnimationPlayer.play("destroyed")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("empty")
		destroyed = true
		var bombobject = bombinstance.instantiate()
		add_child(bombobject)
		await get_tree().create_timer(5).timeout
		queue_free()
