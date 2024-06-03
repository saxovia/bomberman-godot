extends Node

@onready var level_slider = $LevelSelectionMenu/LevelSlider
@onready var round_slider = $LevelSelectionMenu/RoundSlider

@onready var current_level = $LevelSelectionMenu/CurrentLevel
@onready var current_rounds = $LevelSelectionMenu/CurrentRounds

@onready var timer = $Lobby/Timer

func reset():
	print("In")
	$MultiMain.show()
	$ConnectMenu/PanelContainer/MarginContainer/VBoxContainer/ConnectGameButton.disabled = false
	$ConnectMenu/MarginContainer/BackButton.disabled = false
	$ConnectMenu/PanelContainer/MarginContainer/VBoxContainer/IPAdress.editable = true

func _ready():
	var leaveLobby_button = $Lobby/Waiting/LeaveLobby
	leaveLobby_button.pressed.connect(_leave_lobby)
	var startGame_button = $Lobby/Waiting/StartGameButton
	startGame_button.pressed.connect(_on_start_pressed)
	
	var gameSettings_button = $Lobby/Waiting/GameSettings
	gameSettings_button.pressed.connect(_on_gameSettings_pressed)
	
	var gameSettingsBack_button = $LevelSelectionMenu/MarginContainer/Button
	gameSettingsBack_button.pressed.connect(_on_gameSettingsBack_pressed)
	
	timer.timeout.connect(_on_timer_timeout)
	
	GameController.player_connected.connect(_on_connection_success)
	GameController.player_disconnected.connect(_on_connection_success)
	GameController.server_disconnected.connect(_on_game_error)
	GameController.connection_failed.connect(_on_connection_failed)
	GameController.hosting_fail.connect(_on_hosting_fail)


func _on_back_pressed():
	$".".hide()
	get_parent().get_node("MainMenu").show()

func _on_gameSettings_pressed():
	updateCurrentLevelLabel()
	updateCurrentRoundsLabel()
	$Lobby.hide()
	$LevelSelectionMenu.show()
	
func _on_gameSettingsBack_pressed():
	$LevelSelectionMenu.hide()
	$Lobby.show()


#STARTING THE HOST
func _on_host_game_button_pressed():
	playacceptsound()
	GameController.create_game()

#STARTING THE CONNECTION
func _on_connect_game_button_pressed():
	playacceptsound()
	var ip = $ConnectMenu/PanelContainer/MarginContainer/VBoxContainer/IPAdress.text
	if not ip.is_valid_ip_address():
		print("Not valid IP adress!")
		return

	$ConnectMenu/PanelContainer/MarginContainer/VBoxContainer/ConnectGameButton.disabled = true
	$ConnectMenu/MarginContainer/BackButton.disabled = true
	$ConnectMenu/PanelContainer/MarginContainer/VBoxContainer/IPAdress.editable = false
	GameController.join_game(ip)

func _on_connection_success(peer_id, player_info={}):
	$MultiMain.hide()
	$ConnectMenu.hide()
	$Lobby.show()
	refresh_lobby()



func _on_connection_failed():
	GameController.remove_multiplayer_peer()
	$ConnectMenu/PanelContainer/MarginContainer/VBoxContainer/ConnectGameButton.disabled = false
	$ConnectMenu/MarginContainer/BackButton.disabled = false
	$ConnectMenu/PanelContainer/MarginContainer/VBoxContainer/IPAdress.editable = true


func _on_game_ended():
	pass


func _on_game_error():
	$ErrorDialog.show()
	$ErrorDialog.dialog_text = "The host left this lobby. Please return"

func _on_hosting_fail():
	$ErrorDialog.show()
	$ErrorDialog.dialog_text = "This IP is already in use!"


func refresh_lobby():
	var players = GameController.players
	$Lobby/Waiting/IPAdress.text = GameController.get_ip()
	$Lobby/Waiting/VBoxContainer/PanelContainer/Player1Container.show()
	if players.size() > 1:
		$Lobby/Waiting/StartGameButton.disabled = false
		$Lobby/Waiting/VBoxContainer/PanelContainer2/Player2Container.show()
	else:
		$Lobby/Waiting/StartGameButton.disabled = true
		$Lobby/Waiting/VBoxContainer/PanelContainer2/Player2Container.hide()
	
	if not multiplayer.is_server():
		$Lobby/Waiting/StartGameButton.hide()
		$Lobby/Waiting/GameSettings.hide()
		$Lobby/Waiting/GameStateLabel.show()

func _on_start_pressed():
	if level_slider.value == 0:
		Global.currentMap="Map1"
	elif level_slider.value == 1:
		Global.currentMap="Map2"
	elif level_slider.value == 2:
		Global.currentMap="Map3"
		
	Global.rounds = int(round_slider.value)
	rpc("handle_startTimer")
	handle_startTimer()
	
	
@rpc("any_peer")
func handle_startTimer():
	timer.start()
	var gameState = $Lobby/Waiting/GameStateLabel
	$Lobby/Waiting/StartGameButton.hide()
	$Lobby/Waiting/LeaveLobby.hide()
	$Lobby/Waiting/GameSettings.hide()
	gameState.text = "Starting in 5..."
	gameState.show()
	
func _process(delta):
	if timer.time_left > 0:
		var gameState = $Lobby/Waiting/GameStateLabel
		gameState.text = "Starting in " + str(int(timer.time_left)) +"..."

func _on_timer_timeout():
	$Lobby.hide()
	GameController.begin_game()

func _on_connect_menu_button_pressed():
	playacceptsound()
	$MultiMain.hide()
	$ConnectMenu.show()
	

func _on_connect_back_button_pressed():
	$ConnectMenu.hide()
	$MultiMain.show()

func _leave_lobby():
	GameController.remove_multiplayer_peer()
	reset()
	$Lobby.hide()
	$MultiMain.show()



func updateCurrentRoundsLabel():
	current_rounds.text = str(round_slider.value)

func updateCurrentLevelLabel():
	if level_slider.value == 0:
		current_level.text = "Dungeon"
	elif level_slider.value == 1:
		current_level.text = "Forest"
	elif level_slider.value == 2:
		current_level.text = "Temple"
	else:
		current_level.text = "Random"


func _on_level_slider_value_changed(value):
	updateCurrentLevelLabel()

func _on_round_slider_value_changed(value):
	updateCurrentRoundsLabel()


func _on_host_menu_button_mouse_entered():
	playhoversound()

func _on_connect_menu_button_mouse_entered():
	playhoversound()

func _on_connect_game_button_mouse_entered():
	playhoversound()

func _on_button_mouse_entered():
	playhoversound()

func playhoversound():
	$HoverStreamPlayer.play()
func playacceptsound():
	$AcceptStreamPlayer.play()
