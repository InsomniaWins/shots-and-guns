extends Control

@onready var main_button_menu_node = $MainButtonMenu
@onready var settings_info_label_node:RichTextLabel = $SettingsInfoLabel
@onready var volume_button_menu_node = $VolumeButtonMenu

func _ready():
	update_info_label()
	main_button_menu_node.activate()


func change_input_mode():
	
	if Settings.input_mode == Settings.InputMode.CONTROLLER:
		Settings.change_input_mode_to_keyboard_and_mouse()
	else:
		Settings.change_input_mode_to_controller()
	
	update_info_label()


func change_window_mode():
	
	var new_window_mode:int = 0
	
	match DisplayServer.window_get_mode(0):
		DisplayServer.WINDOW_MODE_WINDOWED:
			new_window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.WINDOW_MODE_MAXIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			new_window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
			new_window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	
	DisplayServer.window_set_mode(new_window_mode)
	
	update_info_label()


func update_info_label():
	settings_info_label_node.text = str(
		"Input Mode: ", "Controller" if Settings.input_mode == Settings.InputMode.CONTROLLER else "Keyboard & Mouse",
		"\n[color=#868188]Some controls will still work with either input mode; however, most will not. (i.e. Aiming)",
		"\n\n",
		"\n[color=#ffffff]Window Mode: ", "Windowed" if DisplayServer.window_get_mode(0) != DisplayServer.WINDOW_MODE_FULLSCREEN else "Fullscreen",
		"\n\n",
		"\n[color=#ffffff]Volume: ", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")),
		"\n[color=#868188]Default volume is 0; ranged from -80 to 6."
		)
		
	


func _on_main_button_menu_menu_selected():
	var selected_button_index:int = main_button_menu_node.selected_button_index
	var button_name:String = main_button_menu_node.button_names[selected_button_index]
	
	
	match button_name:
		"BACK":
			Settings.save_settings()
			SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")
			
		
		"INPUT MODE":
			change_input_mode()
		
		"WINDOW MODE":
			change_window_mode()
		
		"VOLUME":
			main_button_menu_node.deactivate()
			volume_button_menu_node.visible = true
			volume_button_menu_node.activate()


func _on_volume_button_menu_menu_selected():
	var button_name = volume_button_menu_node.button_names[volume_button_menu_node.selected_button_index]
	
	var master_bus_index:int = AudioServer.get_bus_index("Master")
	
	match button_name:
		"BACK":
			volume_button_menu_node.visible = false
			volume_button_menu_node.deactivate()
			main_button_menu_node.activate()
		"INCREASE":
			AudioServer.set_bus_volume_db(
				master_bus_index,
				min(6, AudioServer.get_bus_volume_db(master_bus_index) + 1)
			)
		"DECREASE":
			AudioServer.set_bus_volume_db(
				master_bus_index,
				max(-80, AudioServer.get_bus_volume_db(master_bus_index) - 1)
			)
	
	update_info_label()
