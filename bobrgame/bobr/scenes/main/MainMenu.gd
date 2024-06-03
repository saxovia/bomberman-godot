extends Control

func _ready():
	$MainContainer/SingleButton.grab_focus()

func _on_single_pressed():
	#get_tree().change_scene_to_file("res://single.tscn")
	Global.previous_scene = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://scenes/menus/load_menu.tscn")
	#add_child(load(("res://scenes/menus/single_menu.tscn")).instantiate())
	
	
	
func _on_multi_pressed():
	get_tree().change_scene_to_file("res://multi.tscn")

func _on_options_pressed():
	SaveManager.load_settings_data()
	get_tree().change_scene_to_file("res://settings.tscn")
	
func _on_quit_pressed():
	get_tree().quit()


