extends MultiplayerSpawner
var waveInstance = preload("res://entities/interactable/bomb/wave.tscn")

func _init():
	spawn_function = _spawn_waves
@rpc("any_peer")
func _spawn_waves(data):
	var wave = waveInstance.instantiate()
	wave.position.x = data[0]
	wave.position.y = data[1]
	wave.add_to_group("waves")

	if Global.current_game_scene == null:
		print("Error: Global.current_game_scene is null")
		return null

	if Global.currentMap == "":
		print("Error: Global.currentMap is not set")
		return null

	var current_map_node = Global.current_game_scene.get_node(Global.currentMap)

	if current_map_node == null:
		print("Error: current_map_node is null. Invalid path: ", Global.currentMap)
		return null

	var tilemap = current_map_node.get_node("insideWalls") as TileMap

	if tilemap == null:
		print("Error: tilemap (insideWalls) is null")
		return null

	var cell = tilemap.local_to_map(wave.position)
	#print("cell: ", cell)

	return wave
