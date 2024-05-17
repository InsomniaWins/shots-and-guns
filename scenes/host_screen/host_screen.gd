extends Control


@onready var port_line_edit_node:LineEdit = $VBoxContainer/PortLineEdit
@onready var username_line_edit_node:LineEdit = $VBoxContainer/UsernameEdit
@onready var status_label_node:Label = $StatusLabel


func _on_back_button_pressed():
	SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")


func _process(delta):
	status_label_node.modulate.a = lerp(status_label_node.modulate.a, 0.0, delta)


func _on_host_button_pressed():
	var port:int = port_line_edit_node.text.to_int()
	var username:String = username_line_edit_node.text
	
	if username.is_empty():
		status_label_node.text = "Username cannot be left blank!"
		status_label_node.modulate = Color.RED
		return
	
	_host_server(port, username)


func _host_server(port:int, username:String):
	
	var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	
	var server_creation_result = peer.create_server(port, 32)
	if server_creation_result != OK:
		status_label_node.text = str("Failed to make server peer: ", server_creation_result)
		status_label_node.modulate = Color.RED
		return
	
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		status_label_node.text = "Failed to start server!"
		status_label_node.modulate = Color.RED
		return
	
	
	multiplayer.multiplayer_peer = peer
	
	
	Network.players[peer.get_unique_id()] = Network.create_new_player_info()
	Network.players[peer.get_unique_id()]["username"] = username
	
	
	SceneManager.change_scene("res://scenes/lobby/lobby.tscn")
	
	
	await SceneManager.changed_scene
	
	
	DisplayServer.window_set_title(str(get_tree().get_multiplayer().get_unique_id()))
	
	var lobby = SceneManager.get_current_scene()
	lobby.update_player_list()
