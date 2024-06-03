extends 'res://addons/gut/test.gd'

var Character = load('res://entities/player/player.gd')
var _character = null;
var _scene = null;
var _bomb = null;

func before_each():
	_character = Character.new();
	_scene = load("res://entities/player/player.tscn").instantiate()
	add_child_autofree(_scene)
	_bomb = load("res://entities/interactable/collectible/bomb_pickupable.tscn").instantiate()
	add_child_autofree(_bomb)
	

func after_each():
	_character.free()

func test_death():
	_character.die();
	assert_false(_character.alive, "Should be false" )

func test_movement():
	_character.move_to(4,6)
	assert_eq(_character.position,Vector2(4,6), "Should be 4,6")

func test_movement2():
	_character.position=Vector2(63,7)
	_character.move_to(4,6)
	assert_eq(_character.position,Vector2(4,6), "Should be 4,6")
	
func test_ready():
	_scene._ready()
	assert_true(_scene.alive, "Should be true")


func test_pickupBomb():
	_scene._on_player_collision_area_area_entered(_bomb.get_child(1))
	assert_eq(_scene.numOfBombs, 2, "Should be 2")

func test_hurt():
	_scene.invincible_active = true
	_scene.playerhurt()
	assert_false(_scene.animhurt, "Should be false")
