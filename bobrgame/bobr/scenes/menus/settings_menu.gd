extends Control

func _on_button_pressed():
	$BackStreamPlayer.play()
	SettingsSignalBus.emit_set_settings_dictionary(SettingsDataContainer.create_settings_dictionary())
	hide()
	get_parent().get_node("MainMenu").show()
