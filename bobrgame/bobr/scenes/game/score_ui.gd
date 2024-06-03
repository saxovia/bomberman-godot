extends Control

@onready var score_label_1 = $Player1UI/ScoreLabel1
@onready var score_label_2 = $Player2UI/ScoreLabel2
@onready var rounds_label = $RoundsUI/RoundsLabel
@onready var player_1ui_2 = $Player2UI
@onready var rounds_ui = $RoundsUI

func _ready():
	if Global.isMultiplayer:
		player_1ui_2.visible = true
	else:
		player_1ui_2.visible = false
		
func _process(delta):
	if Global.isMultiplayer:
		var scores = GameController.showScore()
		if scores.size() != 0:
			score_label_1.text = str( scores[0])
			score_label_2.text = str( scores[1])
		var rounds = Global.rounds
		"""if rounds % 2 == 1:
			rounds = rounds / 2 + 1
		else:
			rounds = rounds / 2		"""
		if Global.rounds < 0:
			rounds_label.text = str("Rounds left: " , 0)
		else:
			
			rounds_label.text = str("Rounds left: " , rounds)
	else:
		#score_label.text = str( GameController.showScore(0) )
		score_label_1.text = str(Global.score)
			
		rounds_label.text = str("Rounds: ", Global.rounds)
