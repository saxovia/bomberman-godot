extends Control
const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "save.json"
@onready var load_1 = $ColorRect/VBoxContainer/Load1
@onready var load_2 = $ColorRect/VBoxContainer/Load2
@onready var load_3 = $ColorRect/VBoxContainer/Load3
@onready var load_4 = $ColorRect/VBoxContainer/Load4

var selectedFile = ""
signal loadprocess(selectedFile)
signal hideScreen()

func _ready():
	updateAllButtons()

func updateAllButtons():
	updateButton(load_1, "save1.json", 1)
	updateButton(load_2, "save2.json", 2)
	updateButton(load_3, "save3.json", 3)
	updateButton(load_4, "save4.json", 4)


func _process(_delta):
	pass
	
func updateButton(button, file, num):
	var path = SAVE_DIR + file
	if FileAccess.file_exists(path):
		var time = FileAccess.get_modified_time(path)
		button.text = "Save File: "+ str(num) + "\n" + str(Time.get_datetime_string_from_unix_time(time)) + "\n "
	else:
		button.text = "No save files detected.\n \n "
	
func loadingscene(filename):
	var path = SAVE_DIR + filename
	if FileAccess.file_exists(path):
		if Global.current_game_scene and not Global.current_game_scene == null:
			GameController.isLoadingData = true
			loadprocess.emit(selectedFile)
		else:
			#var scene_instance = load("res://scenes/game/game.tscn")
			Global.loading_file = selectedFile
			#get_tree().change_scene_to_file(Global.previous_scene)
			GameController.create_game()
			GameController.initLoad(path)
			#get_tree().change_scene_to_file(scene_instance.resource_path)

func _on_load_1_pressed():
	selectedFile = "save1.json"

func _on_load_2_pressed():
	selectedFile = "save2.json"

func _on_load_3_pressed():
	selectedFile = "save3.json"

func _on_load_4_pressed():
	selectedFile = "save4.json"

func _on_load_game_pressed():
	loadingscene(selectedFile)


func _on_back_button_pressed():
	if Global.current_game_scene and not Global.current_game_scene == null:
		hideScreen.emit()
	else:
		get_tree().change_scene_to_file(Global.previous_scene)
