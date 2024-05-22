extends Control

var editing_port:bool = false
var current_port:String = "25565"

@onready var main_menu_node = $MainMenu
@onready var current_port_label_node = $ConnectionInfo/PortLabel
@onready var status_label_node:Label = $StatusLabel


func _on_back_button_pressed():
	SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")


func _process(delta):
	status_label_node.modulate.a = lerp(status_label_node.modulate.a, 0.0, delta)


func _host_server(port:int, username:String):
	
	var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	
	var server_creation_result = peer.create_server(port, 32)
	if server_creation_result != OK:
		status_label_node.text = str("Failed to make server peer: ", server_creation_result)
		status_label_node.modulate = Color.RED
		main_menu_node.activate()
		return
	
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		status_label_node.text = "Failed to start server!"
		status_label_node.modulate = Color.RED
		main_menu_node.activate()
		return
	
	
	multiplayer.multiplayer_peer = peer
	
	
	Network.players[peer.get_unique_id()] = Network.create_new_player_info(
		Network.my_information.username,
		Network.my_information.hat,
		Network.my_information.color
	)
	
	
	SceneManager.change_scene("res://scenes/lobby/lobby.tscn")
	
	
	await SceneManager.changed_scene
	
	
	DisplayServer.window_set_title(str(get_tree().get_multiplayer().get_unique_id()))
	
	var lobby = SceneManager.get_current_scene()
	lobby.update_player_list()



func _input(event):
	if event is InputEventKey:
		if event.pressed and !event.echo:
			var key_string:String = event.as_text_keycode()
			
			if key_string.length() > 1:
				
				if key_string == "Enter" or key_string == "Escape" or key_string == "Enter":
					editing_port = false
					main_menu_node.activate()
					return
				elif key_string == "Backspace":
					if editing_port:
						current_port = current_port.substr(0, current_port.length()-1)
					update_current_information()
					return
				elif key_string == "Period":
					key_string = "."
				else:
					return
			
			if editing_port:
				current_port = current_port + key_string
			update_current_information()


func update_current_information() -> void:
	current_port_label_node.text = "PORT: " + current_port


func _on_main_menu_menu_selected():
	var button_name = main_menu_node.button_names[main_menu_node.selected_button_index]
	
	match button_name:
		"EDIT PORT":
			editing_port = true
			main_menu_node.deactivate()
		"HOST":
			main_menu_node.deactivate()
			_host_server(current_port.to_int(), Network.my_information.username)
		"BACK":
			SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")
