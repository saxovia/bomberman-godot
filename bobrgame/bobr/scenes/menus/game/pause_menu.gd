extends Control

@onready var game = $"../../"
var pauseToLoadScreen = false
var pauseToSaveScreen = false

func _on_resume_pressed():
	game.pauseMenu()


func _on_quit_pressed():
	GameController.remove_multiplayer_peer()
	get_tree().quit()


func _on_to_main_menu_pressed():
	GameController.remove_multiplayer_peer()
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_load_game_pressed():
	pauseToLoadScreen = true

func _on_save_game_pressed():
	pauseToSaveScreen = true

func _on_restart_pressed():
	GameController.isLoadingData = false
	GameController.begin_game()

func _ready():
	if Global.isMultiplayer:
		$MarginContainer/VBoxContainer/SaveGame.hide()
		$MarginContainer/VBoxContainer/LoadGame.hide()
		$MarginContainer/VBoxContainer/Restart.hide()
		
	


