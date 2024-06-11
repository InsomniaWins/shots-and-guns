extends Control

var current_port:String = str(Settings.default_port)

@onready var main_menu_node = $MainMenu
@onready var port_edit_node := $PortEdit
@onready var status_label_node:Label = $StatusLabel
@onready var port_edit_controller_keyboard_input_node := $PortEditControllerKeyboardInput

func _ready():
	current_port = str(Settings.default_port)
	port_edit_node.text = current_port

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
	
	var lobby = SceneManager.get_current_scene()
	lobby.update_player_list()


func update_current_information() -> void:
	port_edit_node.text = current_port


func _on_main_menu_menu_selected():
	var button_name = main_menu_node.button_names[main_menu_node.selected_button_index]
	
	match button_name:
		"EDIT PORT":
			port_edit_node.grab_focus()
		"HOST":
			main_menu_node.deactivate()
			_host_server(current_port.to_int(), Network.my_information.username)
		"BACK":
			SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")


func _on_port_edit_text_submitted(new_text):
	port_edit_node.text = str(new_text.to_int())
	port_edit_node.release_focus()
	main_menu_node.activate()
	
	Settings.default_port = port_edit_node.text.to_int()
	Settings.save_settings()

