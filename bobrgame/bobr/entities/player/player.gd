extends CharacterBody2D

@export var move_speed: float = 140
@export var alive:bool = true
@export var starting_direction: Vector2 = Vector2(0,1)
@export var synced_position := Vector2()
@onready var anim = $AnimatedSprite2D
@onready var animblue = $AnimatedSprite2D2

@onready var collisionarea = $PlayerCollisionArea
@onready var inputs = $Inputs

var bombinstance = preload("res://entities/interactable/bomb/bomb.tscn")
var obstacleinstance = preload("res://entities/interactable/destructible/crate.tscn")
var playerPos = position


var requestOnce = false
var isHurt = false
var MAXNUMOFBOMBS = 5
var MAXNUMOFOBSTACLES = 3
var numOfBombs = 1
var todetonate = []
var numOfDetonators = 0
var numOfObstacles = 0
var numOfExtenders = 0

var animplacebomb = false
var animhurt = false

var ghost_active = false
var in_walls = false
var just_placed_obstacle = false

var invincible_active = false

var speed_active = false



func _ready():
	alive = true
	position = synced_position
	update_animation_parameters(starting_direction)
	if str(name).is_valid_int():
		get_node("Inputs/InputSync").set_multiplayer_authority(str(name).to_int())
	set_physics_process(true)
	if ghost_active:
		#alternatively a crate can be spawned directly under the player so that the flicker is visible
		activate_ghost(self)
		await get_tree().create_timer(5).timeout
		deactivate_ghost(self)
		ghost_active = false
	if invincible_active:
		activate_invincible(self)
		await get_tree().create_timer(5).timeout
		deactivate_invincible(self)
		invincible_active = false
	if speed_active:
		move_speed *= 1.5
		await get_tree().create_timer(5).timeout
		speed_active = false
		move_speed /= 1.5

func _physics_process(_delta: float):
	if alive:
		if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name):
			# The client which this player represent will update the controls state, and notify it to everyone.
			inputs.update()
			if Input.is_action_just_pressed("place_obstacle"):
				if numOfObstacles > 0:
					$PutDownObstacleStreamPlayer.play()
					just_placed_obstacle = true
					handle_spawnObstacle(position)
					await get_tree().create_timer(1).timeout
					just_placed_obstacle = false
					numOfObstacles -= 1
			if Input.is_action_just_pressed("place_bomb"):
				if(numOfBombs > 0 and todetonate.size() <= 1 and not just_placed_obstacle):
					$PutDownBombStreamPlayer.play()
					animplacebomb = true
					$Timer.start(0.2)
					handle_spawnBomb(position, name)
					numOfBombs -= 1
					if numOfDetonators == 0:
						handle_detonateBomb(name)
			if Input.is_action_just_pressed("detonate_bomb"):
				if todetonate.size() > 0 and numOfDetonators > 0:
					numOfDetonators -= 1
					handle_detonateBomb(name)

					


		if multiplayer.multiplayer_peer == null or is_multiplayer_authority():
			synced_position = position
		else:
			position = synced_position
			

		velocity = inputs.motion * move_speed
		
		move_and_slide()
		update_animation_parameters(inputs.motion)
		
		velocity = velocity
		


	
	var currentCollidingBodies = collisionarea.get_overlapping_bodies()
	if currentCollidingBodies.size() != 0:
		for i in range(currentCollidingBodies.size()):
			var thisbody = currentCollidingBodies[i]
			if thisbody is Waves and thisbody.deadly or (thisbody is Bombs and thisbody.isExploding == true):
				$Timer.start(0.2)
				playerhurt() #or get_parent().playerDied()
				# print() - it works without it now
func move_to(x,y):
	synced_position.x = x
	synced_position.y = y
	position.x = x
	position.y = y
	
@rpc("any_peer")
func handle_spawnBomb(position,owner):
	if is_multiplayer_authority():
		var newBomb = get_node("../../Spawners/BombSpawner").spawn([position,owner])
		todetonate.append(newBomb)	
	else:
		rpc_id(1,"handle_spawnBomb",position,owner)
		
@rpc("any_peer")
func handle_detonateBomb(owner):
	if is_multiplayer_authority():
		detonateBomb(owner)	
	else:
		rpc_id(1,"handle_detonateBomb",owner)
		
@rpc("any_peer")
func handle_spawnObstacle(position):
	if is_multiplayer_authority():
		var newObstacle = get_node("../../Spawners/ObstacleSpawner")._spawn_obstacle(position)
		get_tree().current_scene.add_child(newObstacle, true)
	else:
		rpc_id(1,"handle_spawnObstacle",position)

func detonateBomb(owner):
	for i in range(todetonate.size()):
		if todetonate[i].playerowner == owner: 
			var bombtodestroy = todetonate.pop_front()
			if numOfExtenders > 0:
				bombtodestroy.extended = true
				numOfExtenders -= 1
			bombtodestroy.detonate.rpc()
		
	
func die():
	alive = false
	self.visible = false
	
func playerhurt():
	if invincible_active:
		return
	animhurt = true
	if not requestOnce:
		if Global.isMultiplayer:
			#GameController.update_player_score(self)
			#print(self)
			GameController.update_score_and_round(self)
			GameController.end_round(self)
			requestOnce = true
		else:
			get_parent().get_parent().playerDied(self)
		die()
	
func update_animation_parameters(dir):
	if dir.x == 1 and alive:
		anim.flip_h = true
	elif dir.x == -1 and alive:
		anim.flip_h = false
		
	if !animhurt and !animplacebomb:
		anim.play("new_animation")
	elif animhurt:
		anim.play("hurt")
	elif animplacebomb:
		anim.play("placedbomb")

func _on_timer_timeout():
	animplacebomb = false
	animhurt = false
	requestOnce = false
	
	
func _on_player_collision_area_area_entered(area):
	#print(area.get_parent().get_children().name)
	if area.get_parent().name == "BombPickupable" and numOfBombs <= MAXNUMOFBOMBS:
		play_powerupsound()
		area.collect()
		numOfBombs += 1
	elif area.get_parent().name == "Obstacle" and numOfObstacles <= MAXNUMOFOBSTACLES:
		play_powerupsound()
		area.collect()
		numOfObstacles += 3

func play_powerupsound():
	$GetPowerUpStreamPlayer.play()
	
func activate_ghost(owner):
	if self == owner: 
		play_powerupsound()
		owner.get_node("AnimatedSprite2D").self_modulate = Color('#ADD8E6')
		owner.get_node("AnimatedSprite2D").self_modulate.a8 = 200
		owner.set_collision_layer_value(6, false)
		owner.set_collision_mask_value(6, false)


func deactivate_ghost(owner):
	if self == owner: 
		get_node("AnimatedSprite2D").self_modulate = Color('#ffffff')
		get_node("AnimatedSprite2D").self_modulate.a8 = 255
		if in_walls:
			get_parent().get_parent().playerDied(self);

		set_collision_layer_value(6, true)
		set_collision_mask_value(6, true)

func _on_area_2d_body_entered(body):
	if body.is_in_group("insideWalls") or body.is_in_group("crates"):
		in_walls = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("insideWalls") or body.is_in_group("crates"):
		in_walls = false

func activate_invincible(owner):
	play_powerupsound()
	if self == owner: 
		get_node("AnimatedSprite2D").self_modulate = Color('gold')

func deactivate_invincible(owner):
	if self == owner: 
		get_node("AnimatedSprite2D").self_modulate = Color('#ffffff')

func _on_enemy_collision_body_entered(body):
	if body.is_in_group("enemies") and body.alive:
		body.handleAttack(self)
