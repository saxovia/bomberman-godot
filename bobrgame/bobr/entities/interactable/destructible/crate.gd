extends StaticBody2D
@onready var hitbox = $hitbox ## Area variable.
@export var destroyed = false ## Flag: if the crate was destroyed.
@export var needsAssignedPowerup = true ## Flag: if the crate needs an assigned Powerup (false with obstacles).
@export var powerUpInstance = load("res://entities/interactable/collectible/bomb_pickupable.tscn") ## Standard instance, to be overwritten.
@export var syncedpowerup = 0 ## Variable for syncing up powerups.
var kms = false ## Flag: turns true when it must be cleaned up from the map.
@onready var despawn_timer = $DespawnTimer ## Timer for despawn.
var skipparentcheck = false ## Flag: helps get past the initial Wave/Bomb collission check, used for a bug fix when using get_parent().
var assignonce = false ## Flag: ensures the crate is only assigned a powerup once.
var onload = false ## Flag: if the game is loading.
@onready var power_up_var_node = $PowerUpVar ## Node for multiplayer syncing (powerup).
var power_up_var = 0 ## Variable for multiplayer syncing (powerup).
var index = 0 ## assigned index/id of the crate.
var runPowerUpDeletionOnce = true ## Flag: ensures deletion only once.
var mutex = Mutex.new() ## Lock for when the crate gets destroyed.

func _ready():
	if onload and destroyed:
		handleCrateLogic()
	elif not onload:
		var rng = RandomNumberGenerator.new()
		syncedpowerup = rng.randi_range(0,5)
		power_up_var = syncedpowerup
		Global.powerUps.append(syncedpowerup)

		if needsAssignedPowerup:
			power_up_var = syncedpowerup
			assignPowerUp()
	
	handle_spawn.rpc(power_up_var)
	assignPowerUp()


func _process(_delta):
	if kms: #called when the child powerup times out, and waits further for the powerup to expire (if it is active).
		if runPowerUpDeletionOnce:
			runPowerUpDeletionOnce = false
			mutex.lock()
			GameController.update_crate_indexes(Global.current_game_scene)
			#print(Global.powerUps)
			Global.powerUps[index] = null
			mutex.unlock()
			await get_tree().create_timer(5).timeout
			mutex.lock()
			GameController.update_crate_indexes(Global.current_game_scene)
			GameController.remove_crate_at(index ,Global.current_game_scene)
			GameController.update_crate_indexes(Global.current_game_scene)
			#print("called")
			mutex.unlock()

## Handles multiplayer powerup syncing.
@rpc("any_peer")
func handle_spawn(new_value):
	if is_multiplayer_authority():
		power_up_var_node.set_meta("PowerUpVar", new_value)
		power_up_var = power_up_var_node.get_meta("PowerUpVar")
		
## Assigns a powerup to the crate.
func assignPowerUp():
	if power_up_var == 0:
		powerUpInstance = load("res://entities/interactable/powerup/ghost.tscn")
	elif power_up_var == 1:
		powerUpInstance = load("res://entities/interactable/powerup/invincible.tscn")
	elif power_up_var == 2:
		powerUpInstance = load("res://entities/interactable/powerup/speed.tscn")
	elif power_up_var == 3:
		powerUpInstance = load("res://entities/interactable/collectible/obstacle.tscn")
	elif power_up_var == 4:
		powerUpInstance = load("res://entities/interactable/powerup/detonator.tscn")
	elif power_up_var == 5:
		powerUpInstance = load("res://entities/interactable/powerup/extender.tscn")

func _physics_process(_delta: float):
	checkoverlappingbodies()
	
## Checks overlapping areas (Bombs and Waves).
func checkoverlappingbodies():
	var currentCollidingBodies = hitbox.get_overlapping_areas()
	if currentCollidingBodies.size() != 0 and not destroyed:
		for i in range(currentCollidingBodies.size()):
			var thisarea = currentCollidingBodies[i]
			if skipparentcheck or (thisarea.get_parent() is Waves or (thisarea.get_parent() is Bombs and thisarea.get_parent().isExploding == true)):
				handleCrateLogic()

## Handles everything related to instancing the powerups themselves,
## and the logic for loading the powerups.
func handleCrateLogic():
	skipparentcheck = true
	if needsAssignedPowerup:
		if Global.isMultiplayer:
			await handle_spawn.rpc(power_up_var)
			await assignPowerUp()
		else:
			if assignonce == false: #assignonce exists to reassing powerups that had been once appended to the Global variables. This is for loading functions
				power_up_var = Global.powerUps.pop_at(index)
				Global.powerUps.insert(index, power_up_var)
				if power_up_var != null: #the powerupvar is null if it had been destroyed once and not picked up
					assignPowerUp()
				assignonce = true

		if power_up_var == null:
			handleBasicDestruction()
			await get_tree().create_timer(5).timeout
			despawn_timer.start(5)
			await despawn_timer
			kms = true
			queue_free()
		elif power_up_var != 3 : #if it is not an obstacle
			var powerUpObject = powerUpInstance.instantiate()
			add_child(powerUpObject)
			handleBasicDestruction()
			await get_tree().create_timer(5).timeout
			if powerUpObject.picked_up_by_player == false:
				despawn_timer.start(5)
				await despawn_timer
				kms = true
				remove_child(powerUpObject)
		else:
			handleBasicDestruction()
			var powerUpObject = powerUpInstance.instantiate()
			add_child(powerUpObject)
			await get_tree().create_timer(5).timeout
			queue_free()
	else:
		handleBasicDestruction()
		queue_free()
		
## Sets the crate to be destructed and plays an animation.
func handleBasicDestruction():
	#print("asd")
	destroyed = true
	$AnimationPlayer.play("destroyed")
	await $AnimationPlayer.animation_finished
