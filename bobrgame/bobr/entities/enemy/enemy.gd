extends CharacterBody2D
class_name Enemy

enum ENEMY_STATE{IDLE, WALK, ATTACK, DIE, SPAWN}
@export var move_speed: float = 40
@export var alive:bool = true


var idle_time: float = 0.8
var spawn_time: float = 1
var attack_time:float = 0.8
var requestOnce = false

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var sprite = $Sprite2D
@onready var walk_timer =$WalkTimer
@onready var hitbox = $hitbox
@onready var navigation_timer =$NavigationTimer
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
signal endGame()

var move_direction : Vector2 = Vector2.ZERO
var current_state : ENEMY_STATE = ENEMY_STATE.SPAWN

func update_animation_parameters():
	if(current_state==ENEMY_STATE.IDLE):
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_walking"] = false
		animation_tree["parameters/conditions/is_attacking"] = false
	elif(current_state==ENEMY_STATE.WALK):
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_walking"] = true
		animation_tree["parameters/conditions/is_attacking"] = false
	elif(current_state==ENEMY_STATE.ATTACK):
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_walking"] = false
		animation_tree["parameters/conditions/is_attacking"] = true
	elif(current_state==ENEMY_STATE.DIE):
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_walking"] = false
		animation_tree["parameters/conditions/is_attacking"] = false
		animation_tree["parameters/conditions/is_dead"] = true

func _ready():
	state_machine.travel("Spawn")
	walk_timer.start(spawn_time)
	checkoverlappingbodies()

func _physics_process(_delta):
	if not current_state == ENEMY_STATE.DIE:
		var dir = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * move_speed
		move_and_slide()
		checkoverlappingbodies()

func makepath():
	var player1 = get_tree().get_nodes_in_group("players")[0]
	if Global.isMultiplayer:
		var player2 = get_tree().get_nodes_in_group("players")[1]
		while player1 == null || player2 == null:
			await get_tree().create_timer(0.5).timeout
			player1 = get_tree().get_nodes_in_group("players")[0]
			player2 = get_tree().get_nodes_in_group("players")[1]
		var d1 = global_position.distance_to(player1.synced_position)
		var d2 = global_position.distance_to(player2.synced_position)
		if d1<d2:
			nav_agent.target_position = player1.synced_position
		else:
			nav_agent.target_position = player2.synced_position
	else:
		while player1 == null:
			await get_tree().create_timer(0.5).timeout
			player1 = get_tree().get_nodes_in_group("players")[0]
		var d1 = global_position.distance_to(player1.synced_position)
		nav_agent.target_position = player1.synced_position
	

func checkoverlappingbodies():
	var currentCollidingBodies = hitbox.get_overlapping_areas()
	if currentCollidingBodies.size() != 0:
		for i in range(currentCollidingBodies.size()):
			var thisarea = currentCollidingBodies[i]
			if (thisarea.get_parent() is Waves) or (thisarea.get_parent() is Bombs and thisarea.get_parent().isExploding == true):
				to_dead()

func to_idle():
	move_speed=0
	navigation_timer.stop()
	state_machine.travel("Idle")
	current_state= ENEMY_STATE.IDLE
	move_direction=Vector2.ZERO
	update_animation_parameters()
	
func to_walk():
	move_speed = 40
	navigation_timer.start()
	state_machine.travel("Walk")
	current_state= ENEMY_STATE.WALK
	update_animation_parameters()
	
func to_attack():
	move_speed=0
	navigation_timer.stop()
	state_machine.travel("Attack")
	current_state= ENEMY_STATE.ATTACK
	move_speed=0
	update_animation_parameters()
func to_dead():
	alive = false
	move_speed=0
	navigation_timer.stop()
	state_machine.travel("Die")
	current_state= ENEMY_STATE.DIE
	update_animation_parameters()
	Global.numOfEnemies -= 1
	if Global.numOfEnemies <= 0 and not Global.isMultiplayer:
		#endGame.emit()
		GameController.signalendgame()
	Global.score += 1
	$CollisionShape2D.disabled = true
	await get_tree().create_timer(2).timeout
	queue_free()
	
	


func _on_area_2d_body_entered(body):
	if body.is_in_group("players") and current_state != ENEMY_STATE.SPAWN and alive:
		handleAttack(body)
		
func handleAttack(player):
	to_attack()
	await get_tree().create_timer(attack_time).timeout
	if Global.isMultiplayer:
		if not requestOnce:
			#GameController.update_player_score(player)
			#GameController.end_round(player)
			player.playerhurt()
	else:
		get_parent().get_parent().playerDied(player)
	to_walk()


func _on_walk_timer_timeout():
	walk_timer.stop()
	navigation_timer.start()
	makepath()
	to_walk()

func _on_navigation_timer_timeout():
	makepath()
