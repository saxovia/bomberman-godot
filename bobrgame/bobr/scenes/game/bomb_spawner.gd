extends MultiplayerSpawner
var bombInstance = preload("res://entities/interactable/bomb/bomb.tscn")

func _init():
	spawn_function = _spawn_bomb
	
func _spawn_bomb(data):
	var bomb = bombInstance.instantiate()
	bomb.position.x = (int(data[0].x))
	bomb.position.y = (int(data[0].y))
	
	#newbombobject.position = position
	bomb.playerowner = data[1]
	bomb.add_to_group("bombs")
	return bomb
