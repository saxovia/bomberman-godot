class_name PlayerKeybindResource
extends Resource
#https://youtu.be/z-vU475Rixk?si=HmB7H6xCO1MklW8e

const MOVE_LEFT : String = "move_left"
const MOVE_RIGHT : String = "move_right"
const MOVE_UP : String = "move_up"
const MOVE_DOWN : String = "move_down"
const PLACE_BOMB : String = "place_bomb"
const DETONATE_BOMB : String = "detonate_bomb"
const PLACE_OBSTACLE : String = "place_obstacle"

@export var DEFAULT_MOVE_LEFT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_RIGHT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_UP_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_DOWN_KEY = InputEventKey.new()
@export var DEFAULT_PLACE_BOMB_KEY = InputEventKey.new()
@export var DEFAULT_DETONATE_BOMB_KEY = InputEventKey.new()
@export var DEFAULT_PLACE_OBSTACLE_KEY = InputEventKey.new()

var move_left_key = InputEventKey.new()
var move_right_key = InputEventKey.new()
var move_up_key = InputEventKey.new()
var move_down_key = InputEventKey.new()
var place_bomb_key = InputEventKey.new()
var detonate_bomb_key = InputEventKey.new()
var place_obstacle_key = InputEventKey.new()




