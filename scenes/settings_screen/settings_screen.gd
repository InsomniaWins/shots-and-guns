extends Control

@onready var main_button_menu_node = $MainButtonMenu
@onready var settings_info_label_node:RichTextLabel = $SettingsInfoLabel


func _ready():
	update_info_label()
	main_button_menu_node.activate()


func change_input_mode():
	
	if Settings.input_mode == Settings.InputMode.CONTROLLER:
		Settings.change_input_mode_to_keyboard_and_mouse()
	else:
		Settings.change_input_mode_to_controller()
	
	update_info_label()


func update_info_label():
	settings_info_label_node.text = str(
		"Input Mode: ", "Controller" if Settings.input_mode == Settings.InputMode.CONTROLLER else "Keyboard & Mouse",
		"\n[color=#868188]Some controls will still work with either input mode; however, most will not."
		)


func _on_main_button_menu_menu_selected():
	var selected_button_index:int = main_button_menu_node.selected_button_index
	var button_name:String = main_button_menu_node.button_names[selected_button_index]
	
	match button_name:
		"BACK":
			SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")
		
		"CHANGE INPUT MODE":
			change_input_mode()
