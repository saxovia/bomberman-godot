extends Node


func _on_audio_stream_player_finished():
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 10
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	$AudioStreamPlayer.play()
	
func playhoversound():
	$HoverStreamPlayer.play()

func _on_single_button_mouse_entered():
	playhoversound()

func _on_multi_button_mouse_entered():
	playhoversound()


func _on_settings_button_mouse_entered():
	playhoversound()


func _on_quit_button_mouse_entered():
	playhoversound()
