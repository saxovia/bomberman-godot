extends 'res://addons/gut/test.gd'

var Enemy = load('res://entities/enemy/enemy.gd')
var _enemy = null;
var _scene = null;

func before_each():
	_enemy = Enemy.new();
	_scene = load("res://entities/enemy/enemy.tscn").instantiate()
	add_child_autofree(_scene)

func after_each():
	_enemy.free()

func test_to_idle():
	_scene.to_idle()
	assert_eq(_scene.move_speed, 0.0, "Should be 0")
	assert_eq(_scene.current_state, _scene.ENEMY_STATE.IDLE, "Should be Idle" )
	assert_eq(_scene.move_direction, Vector2.ZERO, "Should be ZERO")
	
func test_to_walk():
	_scene.to_walk()
	assert_eq(_scene.move_speed, 40.0, "Should be 40")
	assert_eq(_scene.current_state, _scene.ENEMY_STATE.WALK, "Should be Walk" )
	
func test_to_attack():
	_scene.to_attack()
	assert_eq(_scene.move_speed, 0.0, "Should be 0")
	assert_eq(_scene.current_state, _scene.ENEMY_STATE.ATTACK, "Should be Attack" )
	assert_eq(_scene.move_direction, Vector2.ZERO, "Should be ZERO")
	

