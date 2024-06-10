extends CanvasLayer

signal resume_selected
signal quit_selected
signal start_game_selected

@onready var main_menu_node := $MainMenu

func _ready():
	main_menu_node.activate()
	
	if multiplayer.is_server():
		var new_button_names:Array = main_menu_node.button_names.duplicate()
		new_button_names.append("START GAME")
		main_menu_node.button_names = new_button_names
		main_menu_node.update_labels()

func _on_main_menu_menu_selected():
	var button_name = main_menu_node.button_names[main_menu_node.selected_button_index]
	
	match button_name:
		
		"RESUME":
			get_viewport().set_input_as_handled()
			resume_selected.emit()
			queue_free()
		
		"QUIT":
			get_viewport().set_input_as_handled()
			quit_selected.emit()
		
		"START GAME":
			get_viewport().set_input_as_handled()
			start_game_selected.emit()
