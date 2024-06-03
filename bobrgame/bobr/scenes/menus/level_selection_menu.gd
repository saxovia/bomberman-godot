extends Control

@onready var level_slider = $LevelSlider
@onready var round_slider = $RoundSlider

@onready var current_level = $CurrentLevel
@onready var current_rounds = $CurrentRounds

# https://www.youtube.com/watch?v=B6kEaQQ71lQ&ab_channel=rayuserphttps://www.youtube.com/watch?v=B6kEaQQ71lQ&ab_channel=rayuserp

func _ready():
	updateCurrentLevelLabel()
	updateCurrentRoundsLabel()
	
func _on_single_new_game_button_pressed():
	$AcceptStreamPlayer.play()
	if level_slider.value == 0:
		Global.currentMap="Map1"
	elif level_slider.value == 1:
		Global.currentMap="Map2"
	elif level_slider.value == 2:
		Global.currentMap="Map3"
	Global.rounds = int(round_slider.value)
	GameController.create_game()
	GameController.begin_game()

func _on_back_pressed():
	$BackStreamPlayer.play()
	self.hide()
	get_parent().get_node("SingleMenu").show()

func updateCurrentLevelLabel():
	if level_slider.value == 0:
		current_level.text = "Dungeon"
	elif level_slider.value == 1:
		current_level.text = "Forest"
	elif level_slider.value == 2:
		current_level.text = "Temple"
	else:
		current_level.text = "Random"


func updateCurrentRoundsLabel():
	current_rounds.text = str(round_slider.value)
	
func _on_level_slider_value_changed(value):
	updateCurrentLevelLabel()


func _on_round_slider_value_changed(value):
	updateCurrentRoundsLabel()


func _on_single_new_game_button_mouse_entered():
	$HoverStreamPlayer.play()


func _on_button_mouse_entered():
	$HoverStreamPlayer.play()

func _on_round_slider_changed():
	Global.rounds = int(round_slider.value)
