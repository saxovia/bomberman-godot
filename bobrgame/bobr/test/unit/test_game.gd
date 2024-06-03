extends 'res://addons/gut/test.gd'

var World = load('res://scenes/game/game.gd')
var _world = null;
var _scene = null;

func before_each():
	_world = World.new();
	_scene = load("res://scenes/game/world.tscn").instantiate()
	add_child_autofree(_scene)

func after_each():
	_world.free()


#func test_crateSpawn():
	#_scene.spawnCrate(2,5)
	#assert_eq(get_tree().get_nodes_in_group("crates")[3].global_position.x, 2.0, "Should be 2" )
	#assert_eq(get_tree().get_nodes_in_group("crates")[3].global_position.y, 5.0, "Should be 5" )
	#
#func test_barrelSpawn():
	#_scene.spawnBarrel(2,5)
	#assert_eq(get_tree().get_nodes_in_group("barrels")[0].global_position.x, 2.0, "Should be 2" )
	#assert_eq(get_tree().get_nodes_in_group("barrels")[0].global_position.y, 5.0, "Should be 5" )
	#
#func test_addCratesAndBarrels():
	#_scene.addBarrelsAndCrates()
	#assert_false(get_tree().get_nodes_in_group("barrels").is_empty(), "Should be false")
	#assert_true(get_tree().get_nodes_in_group("crates").size() > 3, "Should be true")
