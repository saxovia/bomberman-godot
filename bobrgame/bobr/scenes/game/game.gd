extends Node2D
@onready var pause_menu = $Menus/PauseMenu
@onready var gameOver_menu = $Menus/GameOverMenu
@onready var load_menu = $Menus/LoadMenu
@onready var save_menu = $Menus/SaveMenu
@onready var player = "Player"
@onready var crate_spawn_timer = $CrateSpawnTimer




"""
 To place an object in the middle of a tile: 
 newobject.position.x = (int(position.x) / TILESIZE) * TILESIZE + (TILESIZE / 2)

TODO:Move this under game!!
"""

var enemyinstance = preload("res://entities/enemy/enemy.tscn")
var crateinstance = preload("res://entities/interactable/destructible/crate.tscn")
var barrelinstance = preload("res://entities/interactable/destructible/barrel.tscn")
var map1 = preload("res://scenes/game/levels/level1.tscn")
var map2 = preload("res://scenes/game/levels/level2.tscn")
var map3 = preload("res://scenes/game/levels/level3.tscn")
var TILESIZE = 32

const SAVE_DIR = "user://saves/" #you can open the save file location at Project->Open User Data Folder
var SAVE_FILE_NAME = "save1.json"
var player_data = PlayerData.new()

@export var paused = false
var spawnTimer

var toload = false

var rng = RandomNumberGenerator.new()
		
	

func _ready():
	Global.current_game_scene = self
	if Global.currentMap==null or Global.currentMap =="Map1":
		var map = map1.instantiate()
		add_child(map)
	elif Global.currentMap =="Map2":
		var map = map2.instantiate()
		add_child(map)
	else:
		var map = map3.instantiate()
		add_child(map)
		
	verify_save_directory(SAVE_DIR)
	if Global.loading_file:
		SAVE_FILE_NAME = Global.loading_file
		load_data(SAVE_DIR + SAVE_FILE_NAME)
		Global.loading_file = null
		
	initGame()

func initGame():
	paused = false
	Global.ended = false
	gameOver_menu.hide()
	pause_menu.hide()
	load_menu.hide()
	save_menu.hide()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		Global.numOfEnemies += 1
	Engine.time_scale = 1
	crate_spawn_timer.start()

func _process(_delta):
	if Input.is_action_just_pressed("pause_game") and not Global.ended:
		pauseMenu()
	if pause_menu.pauseToLoadScreen:
		loadMenu()
	if pause_menu.pauseToSaveScreen:
		saveMenu()


func pauseMenu():
	if paused:
		pause_menu.hide()
		if not Global.isMultiplayer:
			Engine.time_scale = 1
	else:
		pause_menu.show()
		if not Global.isMultiplayer:
			Engine.time_scale = 0
	paused = !paused

func loadMenu():
	pause_menu.hide()
	load_menu.updateAllButtons()
	load_menu.show()
func saveMenu():
	pause_menu.hide()
	save_menu.updateAllButtons()
	save_menu.show()
	
func playerDied(player:CharacterBody2D):
	music_end_game()
	if not toload:
		if player.invincible_active:
			return
		Global.ended = true
		player.die()
		Engine.time_scale = 0
		gameOver_menu.setResult("lost")
		gameOver_menu.show()
		
func winGameSinglePlayer():
	music_end_game()
	Global.ended = true
	Engine.time_scale = 0
	gameOver_menu.setResult("won")
	gameOver_menu.show()
	
func endMultiRound(players, currentPlayer):
	music_end_game()
	await get_tree().create_timer(2.5).timeout
	var sumscores = 0
	#GameController.update_rounds()
	for key in players.values():
		sumscores += key["score"]
	#print(sumscores,"and" , Global.rounds )
	await get_tree().create_timer(1).timeout
	if Global.ended:
		#print("ending")
		endMultiGame(players, currentPlayer)
	else:
		if is_multiplayer_authority():
		#print("asking for new game")
			GameController.ask_for_newgame()

func endMultiGame(players, currentPlayer):
	if multiplayer.is_server():
		var otherplayerdata
		var currentplayerdata
		for key in players.values():
			if str(key["id"]) != str(currentPlayer.name):
				otherplayerdata = key
			else:
				currentplayerdata = key
		if otherplayerdata["score"] > currentplayerdata["score"]:
			setLostGame()
		elif otherplayerdata["score"] == currentplayerdata["score"]:
			setDrawGame()
		else:
			setWonGame()
	else:
		var otherplayerdata
		var currentplayerdata
		for key in players.values():
			if str(key["id"]) != str(currentPlayer.name):
				otherplayerdata = key
			else:
				currentplayerdata = key
		if otherplayerdata["score"] < currentplayerdata["score"]:
			setLostGame()
		elif otherplayerdata["score"] == currentplayerdata["score"]:
			setDrawGame()
		else:
			setWonGame()

		
func setLostGame():
	Global.ended = true
	Engine.time_scale = 0
	gameOver_menu.setResult("lost")
	gameOver_menu.show()
func setWonGame():
	Global.ended = true
	if not Global.isMultiplayer:
		await get_tree().create_timer(2).timeout
		Engine.time_scale = 0
		#print(Global.rounds)
		Global.rounds -= 1
		if Global.rounds <= 0:
			gameOver_menu.setResult("won")
			gameOver_menu.show()
		else:
			GameController.ask_for_newgame()
	else:
		Engine.time_scale = 0
		gameOver_menu.setResult("won")
		gameOver_menu.show()
	
func setDrawGame():
	Global.ended = true
	Engine.time_scale = 0
	gameOver_menu.setResult("draw")
	gameOver_menu.show()
	
func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path)
	
func sync_game_to_data(): #used on saving
	player_data = PlayerData.new()
	for child in get_tree().get_nodes_in_group("players"):
		player = child
	
	player_data.p1global_position.x = player.synced_position.x
	player_data.p1global_position.y = player.synced_position.y
	player_data.score = Global.score
	player_data.p1numOfBombs = player.numOfBombs
	player_data.p1numOfDetonators = player.numOfDetonators
	player_data.numOfObstacles = player.numOfObstacles
	player_data.numOfExtenders = player.numOfExtenders
	
	player_data.mapType = Global.currentMap
	player_data.ghost_active = player.ghost_active
	player_data.in_walls = player.in_walls
	player_data.invincible_active = player.invincible_active
	player_data.speed_active = player.speed_active
	
	player_data.enemyPositions = []
	player_data.cratePositions = []
	player_data.isCrateAssigned = []
	player_data.barrelPositions = []
	for child in get_tree().get_nodes_in_group("enemies"):
		if child.alive:
			player_data.enemyPositions.append(child.position)
	for child in get_tree().get_nodes_in_group("crates"):
		#if not child.destroyed:
		player_data.cratePositions.append(child.position)
		var temp = [child.needsAssignedPowerup, child.skipparentcheck]
		player_data.isCrateAssigned.append(temp)
		player_data.isCrateDestroyed.append(child.destroyed)
		#print(player_data.cratePositions)
	for child in get_tree().get_nodes_in_group("barrels"):
		if not child.destroyed:
			player_data.barrelPositions.append(child.position)
	#obstacle positions
	
func save_data(path: String):
	var file = FileAccess.open(path, FileAccess.WRITE_READ)
	if file == null:
		print(FileAccess.get_open_error())
		return
	#print(Global.powerUps, "on save non destroyed")
	sync_game_to_data()
	var data = {
		"player_data": {
			"score": player_data.score,
			"p1global_position":{
				"x": player_data.p1global_position.x,
				"y": player_data.p1global_position.y
			},
			"p1numOfBombs": player_data.p1numOfBombs,
			"p1todetonate": player_data.p1todetonate,
			"p1numOfDetonators": player_data.p1numOfDetonators,
			"numOfExtenders" : player_data.numOfExtenders,
			"p1activePowerUp": false,
			"numOfObstacles": player_data.numOfObstacles,
			"mapType": Global.currentMap,
			"enemyPositions": array_of_positions_to_json(player_data.enemyPositions),
			"cratePositions": array_of_positions_to_json(player_data.cratePositions), #extend this with needs powerup or not
			"isCrateAssigned" : (player_data.isCrateAssigned),
			"barrelPositions": array_of_positions_to_json(player_data.barrelPositions),
			"powerups" : Global.powerUps,
			"ghost_active" : player_data.ghost_active,
			"in_walls" : player_data.in_walls,
			"invincible_active" : player_data.invincible_active,
			"speed_active" : player_data.speed_active,
			"isCrateDestroyed" : (player_data.isCrateDestroyed)
		}
	}
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	
func array_of_positions_to_json(array):
	var json = "{"
	for i in range(array.size()):
		if i > 0:
			json += ","
		json += "[" + str(round(array[i].x)) + "," + str(round(array[i].y)) + "]"
	json += "}"
	return json

	



func load_data(path : String):
	toload = true
	player_data = PlayerData.new()
	GameController.initLoad(path)

	
"""
func _on_save_pressed():
	save_data(SAVE_DIR + SAVE_FILE_NAME)


func _on_load_pressed():
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	"""
	
func _on_load_menu_loadprocess(selectedFile):
	SAVE_FILE_NAME = selectedFile
	pauseMenu()
	pause_menu.pauseToLoadScreen = false
	load_menu.hide()
	load_data(SAVE_DIR + SAVE_FILE_NAME)


func _on_save_menu_saveprocess(selectedFile):
	SAVE_FILE_NAME = selectedFile
	pauseMenu()
	pause_menu.pauseToSaveScreen = false
	save_menu.hide()
	print(SAVE_DIR + SAVE_FILE_NAME)
	save_data(SAVE_DIR + SAVE_FILE_NAME)

func _on_load_menu_hide_screen():
	pauseMenu()
	pause_menu.pauseToLoadScreen = false
	load_menu.hide()

func _on_save_menu_hide_screen():
	pauseMenu()
	pause_menu.pauseToSaveScreen = false
	save_menu.hide()

func _on_connection_lost():
	GameController.remove_multiplayer_peer()
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_connection_lost_visibility_changed():
	if $ConnectionLost.visible:
		Engine.time_scale = 0


func _on_enemy_end_game():
	if not Global.ended:
		music_end_game()
		await get_tree().create_timer(1.5).timeout
		setWonGame()



func _on_crate_spawn_timer_timeout():
	GameController.generateCratesAndBarrels(Global.current_game_scene)
	crate_spawn_timer.start()


func _on_standard_music_loop_finished():
	if not Global.ended:
		$StandardMusicLoop.play()
	
func music_end_game():
	$StandardMusicLoop.stop()
	$StandardMusicLoop.stream_paused = true
	$EndMusic.play()
	
