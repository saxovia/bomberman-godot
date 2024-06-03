extends 'res://addons/gut/test.gd'

var Ghost = load('res://entities/interactable/powerup/ghost.gd')
var Invincible = load('res://entities/interactable/powerup/invincible.gd')
var Speed = load('res://entities/interactable/powerup/speed.gd')
var _ghost = null;
var _invincible = null;
var _speed = null;
var _ghost_scene = null;
var _invincible_scene = null;
var _speed_scene = null;
var _character = null;

func before_each():
	_ghost = Ghost.new();
	_invincible = Invincible.new()
	_speed = Speed.new()
	_ghost_scene = load("res://entities/interactable/powerup/ghost.tscn").instantiate()
	add_child_autofree(_ghost_scene)
	_invincible_scene = load("res://entities/interactable/powerup/invincible.tscn").instantiate()
	add_child_autofree(_invincible_scene)
	_speed_scene = load("res://entities/interactable/powerup/speed.tscn").instantiate()
	add_child_autofree(_speed_scene)
	_character = load("res://entities/player/player.tscn").instantiate()
	add_child_autofree(_character)
func after_each():
	_ghost.free()
	_invincible.free()
	_speed.free()
	
func test_ghost():
	_ghost_scene.picked_up_by_player=true
	_ghost_scene._on_area_2d_body_entered(_character)
	assert_true(_character.ghost_active, "Should be true")
	
func test_invincible():
	_invincible_scene.picked_up_by_player=true
	_invincible_scene._on_area_2d_body_entered(_character)
	assert_true(_character.invincible_active, "Should be true")
	
func test_speed():
	var speed = _character.move_speed
	_speed_scene.picked_up_by_player=true
	_speed_scene._on_area_2d_body_entered(_character)
	assert_true(_character.speed_active, "Should be true")
	assert_eq(_character.move_speed, speed*1.5)
