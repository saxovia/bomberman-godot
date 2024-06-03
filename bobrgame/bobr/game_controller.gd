extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal connection_failed
signal server_disconnected
signal hosting_fail
signal game_ended

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 2

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players    = {}
var player_info = {"id": 0, "score":0}
var ip: String = DEFAULT_SERVER_IP

var isLoadingData = false

var player_data = PlayerData.new()
var data

var players_loaded = 0



func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	ip = address
	multiplayer.multiplayer_peer = peer
	player_info = {"id": multiplayer.get_unique_id(), "score": 0}
	#players[2] = player_info


func create_game():
	print("Creating server...")
	var peer = ENetMultiplayerPeer.new()
	ip = DEFAULT_SERVER_IP
	peer.set_bind_ip(ip)
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	var tries = 0
	while tries < 5 and error:
		ip = "127.0.0." + str(tries + 2)
		peer.set_bind_ip(ip)
		error = peer.create_server(PORT, MAX_CONNECTIONS)
		print("Host failed, the IP ", ip, " is already in use")
		tries += 1
	if error:
		hosting_fail.emit()
		return
	multiplayer.multiplayer_peer = peer
	player_info = {"id": multiplayer.get_unique_id(), "score": 0}
	players[1] = player_info
	#print(players[1])
	player_connected.emit(1, player_info)



func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	#get_tree().change_scene_to_file(game_scene_path)
	pass
	
@rpc("any_peer", "call_local")
func set_game_multi():
	Global.isMultiplayer = true

@rpc("any_peer", "call_local")
func set_powerups(): #doesnt assign powerups, just syncs up Global.powerUps
	if is_multiplayer_authority():
		var world = get_tree().get_root().get_node("World")
		var j = 0
		for child in world.get_tree().get_nodes_in_group("crates"):
			Global.powerUps[j] = child.power_up_var
			if len(Global.powerUps) - 1 > j:
				j += 1
				
@rpc("any_peer")
func sync_player_avatar_data(id):
	if is_multiplayer_authority():
		for player in Global.current_game_scene.get_node("Players").get_children():
			if player.name != str(id):
				player.animblue.visible = true
				player.anim.visible = false
				player.anim = player.animblue
				player.anim.visible = true
		rpc("sync_player_avatar_data", id)
	else:
		for player in Global.current_game_scene.get_node("Players").get_children():
			if player.name != str(id):
				player.animblue.visible = true
				player.anim.visible = false
				player.anim = player.animblue
				player.anim.visible = true

			
func update_crate_indexes(world):
	#remove_destroyed_crates(world) #for safety
	var ind = 0
	for crate in world.get_node("Crates").get_children():
		#print(crate.index, "before")
		crate.index = ind
		#print(crate.index, "after")
		ind += 1
	#print(Global.powerUps)
	
func remove_destroyed_crates(world): #unused
	for crate in world.get_node("Crates").get_children():
		for p in range(len(Global.powerUps)):
			if p == crate.index and Global.powerUps[p] == null:
				crate.queue_free()
	for i in range(len(Global.powerUps)):
		#print(Global.powerUps[i])
		if Global.powerUps[i] == null:
			Global.powerUps.remove_at(i)
			break
			
func remove_crate_at(index, world):
	#update_crate_indexes(world)
	for crate in world.get_node("Crates").get_children():
		for p in range(len(Global.powerUps)):
			if p == index and Global.powerUps[p] == null and p == crate.index:
				#print("asdasdasdasd")
				crate.queue_free()
	
	for i in range(len(Global.powerUps)):
		if Global.powerUps[i] == null and i == index:
			Global.powerUps.remove_at(i)
			break
	#update_crate_indexes(world)
# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			print("STARTING GAME...")


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)


@rpc("call_local")
func load_world():
	print("LOADING WORLD")
	# Change scene.
	if(isLoadingData):
		Global.score = int(data.player_data.score)
		Global.currentMap = data.player_data.mapType
	var world = load("res://scenes/game/world.tscn").instantiate()
	var tree = get_tree()	
	var old_scene = tree.current_scene	
	tree.root.remove_child(old_scene)
	tree.root.add_child(world)
	tree.current_scene = world
	if not old_scene == null:
		old_scene.queue_free()
	
	get_tree().set_pause(false)

func begin_game():
	syncMaps.rpc(Global.currentMap)
	sync_rounds.rpc(Global.rounds)
	
	Global.numOfEnemies = 0
	Global.score = 0
	assert(multiplayer.is_server())
	if players.size() > 1:
		set_game_multi.rpc()
	else:
		Global.isMultiplayer = false
	load_world.rpc()
	var world = get_tree().get_root().get_node("World")
	if not isLoadingData:
		var playerInstance = load("res://entities/player/player.tscn")
		# Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
		var spawn_points = {}
		spawn_points[1] = 0 # Server in spawn point 0.
		var spawn_point_idx = 1
		for p in players:
			spawn_points[p] = spawn_point_idx
			spawn_point_idx += 1

		# Generating players
		for p_id in players:
			#Todo: Move spawnpoints under Map
			var spawn_pos = world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
			var player = playerInstance.instantiate()
			player.synced_position = spawn_pos
			player.name = str(p_id)
			world.get_node("Players").add_child(player)

		sync_player_avatar_data(1)
		
		generateCratesAndBarrels(world)

		# Generating crates and barrels
		
			
	else:
		loadData(world)

func generateCratesAndBarrels(world):
	var crateInstance = load("res://entities/interactable/destructible/crate.tscn")
	var barrelInstance = load("res://entities/interactable/destructible/barrel.tscn")
	var rng = RandomNumberGenerator.new()
	var topLeft : Marker2D = world.get_node(str(Global.currentMap)+ "/Edges/1")
	var topRight : Marker2D = world.get_node(str(Global.currentMap)+ "/Edges/2")
	var bottomLeft : Marker2D = world.get_node(str(Global.currentMap)+ "/Edges/3")
	var bottomRight : Marker2D = world.get_node(str(Global.currentMap)+ "/Edges/4")
	
	for i in range(rng.randi_range(3, 5)):
		var crate = crateInstance.instantiate()
		crate.global_position.x = rng.randi_range(topLeft.global_position.x, topRight.global_position.x)
		crate.global_position.y = rng.randi_range(topLeft.global_position.y, bottomLeft.global_position.y)
		crate.add_to_group("crates")
		world.get_node("Crates").add_child(crate,true)
		
	var ind = 0
	for crate in world.get_node("Crates").get_children():
		crate.index = ind
		ind += 1
	set_powerups()
	
	for i in range(rng.randi_range(3, 5)):
		var barrel = barrelInstance.instantiate()
		barrel.global_position.x = rng.randi_range(topLeft.global_position.x, topRight.global_position.x)
		barrel.global_position.y = rng.randi_range(topLeft.global_position.y, bottomLeft.global_position.y)
		barrel.add_to_group("barrels")
		world.get_node("Barrels").add_child(barrel,true)
		
func loadData(world):
	player_data = PlayerData.new()
	world.toload = true
	var playerInstance = load("res://entities/player/player.tscn")
	var crateInstance = load("res://entities/interactable/destructible/crate.tscn")
	var barrelInstance = load("res://entities/interactable/destructible/barrel.tscn")
	var enemyInstance = load("res://entities/enemy/enemy.tscn")
	
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	
	for p_id in spawn_points:
		var player = playerInstance.instantiate()
		player.name = str(p_id)
		
		player_data.p1global_position = Vector2(data.player_data.p1global_position.x, data.player_data.p1global_position.y)
		#print(data.player_data.p1global_position.x, " ",data.player_data.p1global_position.y)
		player.synced_position.x = data.player_data.p1global_position.x
		player.synced_position.y = data.player_data.p1global_position.y
		player.position.x = data.player_data.p1global_position.x
		player.position.y = data.player_data.p1global_position.y
		
		player.ghost_active = data.player_data.ghost_active
		player.in_walls = data.player_data.in_walls
		player.invincible_active = data.player_data.invincible_active
		player.speed_active = data.player_data.speed_active
		player.numOfDetonators = int(data.player_data.p1numOfDetonators)
		player.numOfExtenders = int(data.player_data.numOfExtenders)
		player.numOfObstacles = int(data.player_data.numOfObstacles)
		player.numOfBombs = int(data.player_data.p1numOfBombs)
		player.numOfDetonators = int(data.player_data.p1numOfDetonators)
		
		world.get_node("Players").add_child(player)
		break
	
	data.player_data.enemyPositions = json_to_array_of_positions(data.player_data.enemyPositions)
	data.player_data.cratePositions = json_to_array_of_positions(data.player_data.cratePositions)
	data.player_data.barrelPositions = json_to_array_of_positions(data.player_data.barrelPositions)
	
	for enemy in world.get_node("Enemies").get_children():
		enemy.queue_free()
	for crate in get_tree().get_nodes_in_group("crates"):
		crate.queue_free()
	for barrel in get_tree().get_nodes_in_group("barrels"):
		barrel.queue_free()
		
	Global.numOfEnemies = 0
	for i in range(len(data.player_data.enemyPositions)):
		var enemy_instance = enemyInstance.instantiate()
		var pos = data.player_data.enemyPositions[i]
		Global.numOfEnemies += 1
		enemy_instance.add_to_group("enemies")
		enemy_instance.position.x = int(pos[0])
		enemy_instance.position.y = int(pos[1])
		#print(enemy_instance.global_position.x, " ", enemy_instance.global_position.y)
		#add_child(enemy_instance)
		world.get_node("Enemies").add_child(enemy_instance)
	Global.powerUps = data.player_data.powerups
	#print(Global.powerUps, "non destroyed ones on load")
	var temp = [] + Global.powerUps.duplicate()

	
	for i in range(len(data.player_data.cratePositions)):

		var crate_instance = crateInstance.instantiate()
		var pos = data.player_data.cratePositions[i]
		crate_instance.index = i
		crate_instance.global_position.x = int(pos[0])
		crate_instance.global_position.y = int(pos[1])
		crate_instance.needsAssignedPowerup = data.player_data.isCrateAssigned[i][0]
		crate_instance.skipparentcheck = data.player_data.isCrateAssigned[i][1]
		crate_instance.destroyed = data.player_data.isCrateDestroyed[i]
		crate_instance.assignonce = false
		crate_instance.onload = true
		#if crate_instance.destroyed:
		#	print(i, crate_instance.index)
		if crate_instance.needsAssignedPowerup:
			crate_instance.power_up_var = temp.pop_at(i)
			#temp.append(crate_instance.power_up_var)
		world.get_node("Crates").add_child(crate_instance, false)
		crate_instance.add_to_group("crates")

	if data.player_data.barrelPositions[0][0] != 0:
		for i in range(len(data.player_data.barrelPositions)):
			var barrel_instance = barrelInstance.instantiate()
			var pos = data.player_data.barrelPositions[i]
			barrel_instance.global_position.x = int(pos[0])
			barrel_instance.global_position.y = int(pos[1])
			world.get_node("Barrels").add_child(barrel_instance)
			barrel_instance.add_to_group("barrels")
	isLoadingData = false
	world.toload = false
	
func initLoad(path : String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file == null:
			print(FileAccess.get_open_error())
			return
		var content = file.get_as_text()
		file.close()
		
		data = JSON.parse_string(content)
		if data == null:
			printerr("Cannot parse %s as a json_string." % [path, content])
			return
		isLoadingData = true
		Global.loading_file = null
		begin_game()
	else:
		printerr("Cannot open non-existent file at %s." % [path])


func json_to_array_of_positions(string):
	var start_index = string.find("{")
	var end_index = string.find("}", start_index)
	var spliced_string = string.substr(start_index + 1, end_index - start_index - 1)
	#var data = string.strip_chars("[]").split(",").split("{")
	var split_array = spliced_string.split("],[")
	var result_array = []
	for item in split_array:
		var trimmed_item = item.lstrip("]")
		trimmed_item = item.lstrip("[")

		var inner_array = []
		for element in trimmed_item.split(","):
			inner_array.append(int(element))
		result_array.append(inner_array)
	
	return result_array


@rpc("any_peer", "reliable")
func _register_player(newPlayer_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = newPlayer_info
	player_connected.emit(new_player_id, newPlayer_info)
	

func _on_player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if multiplayer.is_server():
			end_game()
	else: # Game is not in progress.
		players.erase(id)
		player_disconnected.emit(id)
	
func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World/ConnectionLost").show()
	Global.isMultiplayer = false
	game_ended.emit()
	players.clear()
	
func end_round(player):
	var world = get_tree().get_root().get_node("World")
	world.endMultiRound(players, player)
	
@rpc("any_peer")
func ask_for_newgame():
	Global.endedMultiRound = false
	Global.requestedGameEnding = false
	if multiplayer.is_server():
		#assignNewMap()
		begin_game()
	else:
		rpc_id(1,"ask_for_newgame")

func assignNewMap():
	if is_multiplayer_authority():
		var rng = RandomNumberGenerator.new()
		var temp = int(rng.randi_range(0, 2))
		if temp == 0:
			Global.currentMap="Map1"
		elif temp == 1:
			Global.currentMap="Map2"
		elif temp == 2:
			Global.currentMap="Map3"
		else:
			Global.currentMap="Map1"
		syncMaps(Global.currentMap)
		
@rpc("any_peer")
func syncMaps(currentMap):
	if is_multiplayer_authority():
		Global.currentMap = str(currentMap)
		rpc("syncMaps", currentMap)
	else:
		Global.currentMap = currentMap
		

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	connection_failed.emit()


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	end_game()
	players.clear()
	server_disconnected.emit()
	
func signalendgame():
	Global.current_game_scene._on_enemy_end_game()
	

@rpc("any_peer")
func endmulti(player):
	if is_multiplayer_authority():
		GameController.update_score_and_round(player)
		GameController.end_round(player)
	else:
		rpc_id(1,"endmulti",player)
	
	
func update_player_score(playerDied):  # Called when the player gets hurt
	if Global.isMultiplayer:
		if multiplayer.is_server():
			update_score_and_round(playerDied.name)
		"""else:
			# Non-authority peers request the authority to update the state
			var otherplayerdata
			var currentplayerdata
			for key in players.values():
				if str(key["id"]) != str(player.name):
					otherplayerdata = key
			otherplayerdata.name = otherplayerdata["id"]
			currentplayerdata.name = currentplayerdata["id"]
			rpc_id(1, "update_score_and_round", currentplayerdata)"""
		if is_multiplayer_authority():
			update_score_and_round(playerDied.name)
	else:
		# Single player mode
		for key in players.values():
			key["score"] += 1
			Global.score = key["score"]
			
@rpc("any_peer")
func update_score_and_round(player_id):
	sync_scores.rpc(players)
	if is_multiplayer_authority():
		#print(player_id, " player called this method")
		#print(players, "  players upon update")
		for key in players.values():
			#print("plaeyrid: ", player_id.name , " lists id: ", key['id'])
			if str(key["id"]) != str(player_id.name):  # Give points to the other player
				key["score"] += 1
				#print("Gave player:", key['id'], "score: ", key["score"])
				break
		Global.rounds -= 1  

	rpc("sync_scores_and_rounds", players, Global.rounds)
	
@rpc("any_peer")
func sync_scores_and_rounds(updated_players, updated_rounds):
	#print("syncing: ", updated_players)
	players = updated_players
	Global.rounds = updated_rounds
	if Global.rounds <= 0:
		#print("ending2")
		setEnded()
		
@rpc("any_peer")		
func setEnded():
	Global.ended = true
	
	"""
func update_score_and_round(playerDied_name):
	#sync_scores.rpc(players)
	print(players, "  players upon update")
	var clientId
	for key in players.values():
		if str(key["id"]) != str(playerDied_name):  # Give points to the other player
			key["score"] += 1
		if (key["id"] != 1):
			clientId = key["id"] 
	print("NE EZ ELOTT")
	print("peer: ",multiplayer.multiplayer_peer.get_unique_id())
	Global.rounds -= 1  
	rpc_id(clientId,"sync_scores_and_rounds", players, Global.rounds)
	sync_scores_and_rounds(players,Global.rounds)
	
@rpc("any_peer")
func sync_scores_and_rounds(updated_players, updated_rounds):
	#print("peer: ",multiplayer.multiplayer_peer.get_unique_id())
	#print(updated_players, updated_rounds)
	#print("syncing: ", updated_players)
	players = updated_players
	Global.rounds = updated_rounds
	if Global.rounds <= 0:
		print("ending2")
		Global.ended = true

>>>>>>> 5753f9f1937efa87bb209ac0a938b888b8c09a89
func update_rounds():
	if not Global.endedMultiRound:
		if is_multiplayer_authority():
			Global.rounds -= 1
			rpc("sync_scores_and_rounds", players, Global.rounds)
			Global.endedMultiRound = true
"""
func showScore():
	sync_scores(players)
	if Global.isMultiplayer:
		var scores = []
		for key in players.values():
			scores.append(key["score"])
		return scores
	else:
		for key in players.values():
			return key["score"]
			
@rpc("any_peer")
func sync_rounds(rounds):
	if is_multiplayer_authority():
		Global.rounds = rounds
		rpc("sync_rounds", rounds)
	else:
		Global.rounds = rounds
	
@rpc("any_peer")
func sync_scores(players2):
	players = players2
	
func get_player_list():
	return players
	
func get_ip():
	return ip
	
