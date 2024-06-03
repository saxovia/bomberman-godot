extends MultiplayerSpawner
var obstacleInstance = preload("res://entities/interactable/destructible/crate.tscn")

func _init():
	spawn_function = _spawn_obstacle
	
func _spawn_obstacle(position):
	var obstacle = obstacleInstance.instantiate()
	obstacle.position.x = (int(position.x) / 32) * 32 + (32 / 2)
	obstacle.position.y = (int(position.y) / 32) * 32 + (32 / 2)
	obstacle.needsAssignedPowerup = false
	return obstacle
