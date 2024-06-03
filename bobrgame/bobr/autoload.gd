extends Node

var previous_scene = ""
var current_game_scene
var currentMap
var isMultiplayer = false
var rounds = 5
var endedMultiRound = false
var requestedGameEnding = false


#used for singleplayer
var loading_file
var powerUps = []
var score = 0
var numOfEnemies = 0
var ended = false



func _ready():
	pass # Replace with function body.

func getCurrentMap():
	if currentMap == null:
		return 1
	return currentMap

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
