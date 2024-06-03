extends Node

var path = "user://saves/settings.json"
var loaded_data = {}

func _ready():
	SettingsSignalBus.set_settings_dictionary.connect(on_settings_save)

	
func on_settings_save(data: Dictionary) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE_READ)
	if file == null:
		print(FileAccess.get_open_error())
		return
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)


func load_settings_data() -> void:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file == null:
			print(FileAccess.get_open_error())
			return
		var content = file.get_as_text()
		file.close()
		
		loaded_data = JSON.parse_string(content)
		if loaded_data == null:
			printerr("Cannot parse %s as a json_string." % [path, content])
			return
		#print(loaded_data)
		SettingsSignalBus.emit_load_settings_data(loaded_data)
	else:
		printerr("Cannot open non-existent file at %s." % [path])
