extends Node

@onready var keybind_resource : PlayerKeybindResource = preload("res://resource/PlayerKeybindDefault.tres")

var loaded_data : Dictionary = {}

func _ready():
	handle_signals()
	create_settings_dictionary()


func create_settings_dictionary() -> Dictionary:
	var settings_container_dict : Dictionary = {
		"keybinds" : create_keybind_dictionary()
	}
	return settings_container_dict
	
func create_keybind_dictionary() -> Dictionary:
	var keybinds_container_dict  = {
		keybind_resource.MOVE_LEFT : keybind_resource.move_left_key,
		keybind_resource.MOVE_RIGHT : keybind_resource.move_right_key,
		keybind_resource.MOVE_UP : keybind_resource.move_up_key,
		keybind_resource.MOVE_DOWN : keybind_resource.move_down_key,
		keybind_resource.PLACE_BOMB : keybind_resource.place_bomb_key,
		keybind_resource.DETONATE_BOMB : keybind_resource.detonate_bomb_key,
		keybind_resource.PLACE_OBSTACLE : keybind_resource.place_obstacle_key
	}
	return keybinds_container_dict
	
func get_keybind(action : String):
	if !loaded_data.has("keybinds"):
		match action:
			keybind_resource.MOVE_LEFT:
				return keybind_resource.DEFAULT_MOVE_LEFT_KEY
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.DEFAULT_MOVE_RIGHT_KEY
			keybind_resource.MOVE_UP:
				return keybind_resource.DEFAULT_MOVE_UP_KEY
			keybind_resource.MOVE_DOWN:
				return keybind_resource.DEFAULT_MOVE_DOWN_KEY
			keybind_resource.PLACE_BOMB:
				return keybind_resource.DEFAULT_PLACE_BOMB_KEY
			keybind_resource.DETONATE_BOMB:
				return keybind_resource.DEFAULT_DETONATE_BOMB_KEY
			keybind_resource.PLACE_OBSTACLE:
				return keybind_resource.DEFAULT_PLACE_OBSTACLE_KEY
	else:
		match action:
			keybind_resource.MOVE_LEFT:
				return keybind_resource.move_left_key
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.move_right_key
			keybind_resource.MOVE_UP:
				return keybind_resource.move_up_key
			keybind_resource.MOVE_DOWN:
				return keybind_resource.move_down_key
			keybind_resource.PLACE_BOMB:
				return keybind_resource.place_bomb_key
			keybind_resource.DETONATE_BOMB:
				return keybind_resource.detonate_bomb_key
			keybind_resource.PLACE_OBSTACLE:
				return keybind_resource.place_obstacle_key
		
func set_keybind(action : String, event) -> void:
	match action:
		keybind_resource.MOVE_LEFT:
			keybind_resource.move_left_key = event
		keybind_resource.MOVE_RIGHT:
			keybind_resource.move_right_key = event
		keybind_resource.MOVE_UP:
			keybind_resource.move_up_key = event
		keybind_resource.MOVE_DOWN:
			keybind_resource.move_down_key = event
		keybind_resource.PLACE_BOMB:
			keybind_resource.place_bomb_key = event
		keybind_resource.DETONATE_BOMB:
			keybind_resource.detonate_bomb_key = event
		keybind_resource.PLACE_OBSTACLE:
			keybind_resource.place_obstacle_key = event
			

	

func on_keybinds_loaded(data : Dictionary):
	var loaded_move_left = InputEventKey.new()
	var loaded_move_right = InputEventKey.new()
	var loaded_move_up = InputEventKey.new()
	var loaded_move_down = InputEventKey.new()
	var loaded_place_bomb = InputEventKey.new()
	var loaded_detonate_bomb = InputEventKey.new()
	var loaded_place_obstacle = InputEventKey.new()
	
	loaded_move_left.set_physical_keycode(int(data.move_left))
	loaded_move_right.set_physical_keycode(int(data.move_right))
	loaded_move_up.set_physical_keycode(int(data.move_up))
	loaded_move_down.set_physical_keycode(int(data.move_down))
	loaded_place_bomb.set_physical_keycode(int(data.place_bomb))
	loaded_detonate_bomb.set_physical_keycode(int(data.detonate_bomb))
	loaded_place_obstacle.set_physical_keycode(int(data.place_obstacle))
	
	keybind_resource.move_left_key = loaded_move_left
	keybind_resource.move_right_key = loaded_move_right
	keybind_resource.move_up_key = loaded_move_up
	keybind_resource.move_down_key = loaded_move_down
	keybind_resource.place_bomb_key = loaded_place_bomb
	keybind_resource.detonate_bomb_key = loaded_detonate_bomb
	keybind_resource.place_obstacle_key = loaded_place_obstacle
	
func on_settings_data_loaded(data: Dictionary) -> void:
	loaded_data = data
	#print(loaded_data)
	on_keybinds_loaded(loaded_data.keybinds)
	
func handle_signals() -> void:
	SettingsSignalBus.load_settings_data.connect(on_settings_data_loaded)
	
