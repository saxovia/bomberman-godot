extends Node
# https://youtu.be/pR3LF04Gq6g?si=XdPqRzpocTjKiHvU


signal set_settings_dictionary(settings_dict : Dictionary)
signal load_settings_data(settings_dict : Dictionary)

func emit_load_settings_data(settings_dict : Dictionary):
	load_settings_data.emit(settings_dict)

func emit_set_settings_dictionary(settings_dict: Dictionary)-> void:
	#print(settings_dict)
	set_settings_dictionary.emit(settings_dict)
