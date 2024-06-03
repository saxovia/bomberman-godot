extends Resource
class_name PlayerData

@export var score = 0 # a scale, - is red player win, + is blue player win

#player specific data
@export var p1global_position = Vector2.ZERO
@export var p1numOfBombs = 0
@export var p1todetonate = []
@export var p1numOfDetonators = 0
@export var p1activePowerUp = false
@export var numOfObstacles = 0
@export var numOfExtenders = 0
@export var ghost_active = false
@export var in_walls = false
@export var just_placed_obstacle = false
@export var invincible_active = false
@export var speed_active = false


#map data
@export var mapType = ""
@export var enemyPositions = []
@export var cratePositions = []
@export var isCrateAssigned = []
#first boolean is for needsAsisgnedPowerup, second boolean is for skipParentCheck
@export var isCrateDestroyed = []
@export var barrelPositions = []
@export var obstaclePositions = []
@export var powerups = []
#@export var destroyedPowerUps = []

