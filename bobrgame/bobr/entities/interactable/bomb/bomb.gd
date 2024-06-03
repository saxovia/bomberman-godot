extends StaticBody2D
class_name Bombs

@onready var wavetimer = $Timer
@onready var effects = $Effects
@onready var timer = $ExplosionTimer
@onready var collision_shape_2d = $CollisionShape2D
@onready var player_body_collision = $playerBodyCollision


const  groupname = "Bombs"
var isExploding = false
var playerowner = null
var initCollissionWithOwner = false
var extended = false

var collisionCheckDict = []



var waveinstance = preload("res://entities/interactable/bomb/wave.tscn")
var waveCollCheck = preload("res://entities/interactable/bomb/waveCollCheck.tscn")
var waves = []

func _start():
	effects.play("RESET")
	
func _ready():
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

func _process(_delta):
	pass

@rpc("call_local")
func detonate():
	var side_size = 1
	
	if extended:
		side_size += 1
		
	if is_multiplayer_authority():
		spawn_coll_check(position, side_size)
		
	$AudioStreamPlayer2D.play()
		
	timer.start()
	effects.play("explosionBlink")
	await timer.timeout
	effects.play("RESET")
	isExploding = true
	get_tree().current_scene.get_tree().get_nodes_in_group("camera")[0].apply_shake()
	$AnimationPlayer.play("explode")
	
	
	wavetimer.start(0.3) #this timer creates the spreading effect
	await wavetimer.timeout

	collisionCheckDict.push_back({
		"position": position
	})

	if is_multiplayer_authority():
		for pos in collisionCheckDict:
			var newWave = get_node("../../Spawners/WaveSpawner").spawn([pos.position.x, pos.position.y])
			get_tree().current_scene.add_child(newWave)
			waves.append(newWave)

	
	await $AnimationPlayer.animation_finished
	wavetimer.start(0.25) 
	await wavetimer.timeout
	for i in range(waves.size()):
		var wave = waves.pop_back()
		wave.queue_free()
	queue_free()

func spawn_coll_check(position, side_size):
	for angle in ["Left", "Right", "Down", "Top"]:
		var collCheck = waveCollCheck.instantiate()
		collCheck.coll_check.connect(on_collision_with_wall)
		
		if angle == "Left":
			collCheck.position.x = position.x - 32
			collCheck.position.y = position.y
		elif angle == "Right":
			collCheck.position.x = position.x + 32
			collCheck.position.y = position.y
		elif angle == "Down":
			collCheck.position.x = position.x
			collCheck.position.y = position.y - 32
		elif angle == "Top":
			collCheck.position.x = position.x
			collCheck.position.y = position.y + 32
		
		get_tree().current_scene.add_child(collCheck)
		collisionCheckDict.push_back({
			"objectID": collCheck.get_instance_id(),
			"position": collCheck.position,
			"angle": angle,
			"index": 1
		})
	
	await get_tree().create_timer(0.5).timeout
	for range in range(1,side_size):
		for angle in ["Left", "Right", "Down", "Top"]:
			for i in range(collisionCheckDict.size()):
				if collisionCheckDict[i]["angle"] == angle and collisionCheckDict[i]["index"] == range:
					var collCheck = waveCollCheck.instantiate()
					collCheck.coll_check.connect(on_collision_with_wall)
					
					if angle == "Left":
						collCheck.position.x = position.x - (32 + 32 * range)
						collCheck.position.y = position.y
					elif angle == "Right":
						collCheck.position.x = position.x + (32 + 32 * range)
						collCheck.position.y = position.y
					elif angle == "Down":
						collCheck.position.x = position.x
						collCheck.position.y = position.y - (32 + 32 * range)
					elif angle == "Top":
						collCheck.position.x = position.x
						collCheck.position.y = position.y + (32 + 32 * range)
					
					get_tree().current_scene.add_child(collCheck)
					collisionCheckDict.push_back({
						"objectID": collCheck.get_instance_id(),
						"position": collCheck.position,
						"angle": angle,
						"index": range
					})
					break
					
		

	
	
	

func on_collision_with_wall(area,body):
	for i in range(collisionCheckDict.size()):
		if collisionCheckDict[i]["objectID"] == area.get_instance_id():
			collisionCheckDict.remove_at(i)
			break
		area.queue_free()

func _on_player_body_collision_body_exited(body):
	if body.name == playerowner and initCollissionWithOwner == false:
		initCollissionWithOwner = true
		set_collision_layer_value(6, true)
		set_collision_mask_value(6, true)
