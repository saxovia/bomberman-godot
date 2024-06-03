extends Control


func _on_single_load_game_button_pressed():
	$AcceptStreamPlayer.play()
	Global.previous_scene = get_tree().current_scene.scene_file_path
	$SingleMenu.hide()
	$LoadMenu.show()
	
	
func _on_single_new_game_button_pressed():
	$AcceptStreamPlayer.play()
	$SingleMenu.hide()
	$LevelSelectionMenu.show()


func _on_back_pressed():
	hide()
	get_parent().get_node("MainMenu").show()
	$BackStreamPlayer.play()



func _on_single_new_game_button_mouse_entered():
	$HoverStreamPlayer.play()


func _on_single_load_game_button_mouse_entered():
	$HoverStreamPlayer.play()
