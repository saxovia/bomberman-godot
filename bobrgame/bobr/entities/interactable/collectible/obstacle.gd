extends Area2D

func collect():
	$"..".get_parent().visible = false
	$"..".queue_free()
