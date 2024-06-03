extends Control
@onready var label = $MarginContainer/VBoxContainer/ResultLabel
@onready var new_game = $MarginContainer/VBoxContainer/NewGame

var gameLost = ""
func setResult(lost):
	gameLost = lost
	if (str(lost) == "lost"):
		label.text = "You Lost!"
	elif (str(lost) == "draw"):
		label.text = "Draw!"
	else:
		label.text = "You won!"
	if Global.isMultiplayer:
		new_game.visible = false
	else:
		new_game.visible = true

func _on_play_again_button_pressed():
	#var scene_tree = get_tree()
	#scene_tree.reload_current_scene()
	if Global.isMultiplayer:
		GameController.end_game()
		print("ending game again")
		get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	else:
		if gameLost:
			GameController.isLoadingData = false
			GameController.begin_game()
		else:
			get_tree().change_scene_to_file("res://scenes/menus/level_selection_menu.tscn")


func _on_back_to_menu_button_pressed():
	GameController.remove_multiplayer_peer()
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

