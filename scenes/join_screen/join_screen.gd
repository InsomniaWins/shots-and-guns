extends Control

@onready var ip_line_edit_node:LineEdit = $VBoxContainer/IpLineEdit
@onready var port_line_edit_node:LineEdit = $VBoxContainer/PortLineEdit
@onready var username_line_edit_node:LineEdit = $VBoxContainer/UsernameEdit
@onready var status_label_node:Label = $StatusLabel

@onready var connect_timer_node:Timer = $ConnectTimer

func _on_back_button_pressed():
	SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")


func _process(delta):
	status_label_node.modulate.a = lerp(status_label_node.modulate.a, 0.0, delta)



func _on_join_button_pressed():
	var ip:String = ip_line_edit_node.text
	var port:int = port_line_edit_node.text.to_int()
	var username:String = username_line_edit_node.text
	
	if username.is_empty():
		status_label_node.text = "Username cannot be left blank!"
		status_label_node.modulate = Color.RED
		return
	
	_join_server(ip, port, username)


func _join_server(ip:String, port:int, username:String) -> void:
	
	var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var client_creation_result:int = peer.create_client(ip, port)
	
	if client_creation_result != OK:
		status_label_node.text = str("Failed to make client peer: ", client_creation_result)
		status_label_node.modulate = Color.RED
		return
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		status_label_node.text = "Failed to join server!"
		status_label_node.modulate = Color.RED
		return
	
	multiplayer.multiplayer_peer = peer
	
	$BackButton.disabled = true
	$VBoxContainer/JoinButton.disabled = true
	
	const TIMEOUT:int = 10
	for i in TIMEOUT:
		
		print("connecting . . . ", i)
		
		connect_timer_node.start()
		await connect_timer_node.timeout
		
		if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING:
			break
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		status_label_node.text = str("Connection took longer than ", TIMEOUT, " seconds, timed-out!")
		status_label_node.modulate = Color.RED
		
		$BackButton.disabled = false
		$VBoxContainer/JoinButton.disabled = false
		
		peer.close()
		return
		
	elif peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		status_label_node.text = "Failed to join server!"
		status_label_node.modulate = Color.RED
		return
	
	Network.players[peer.get_unique_id()] = Network.create_new_player_info()
	Network.players[peer.get_unique_id()]["username"] = username
	
	Network.send_player_info_to_server({
		"username": username
	})
	
	var peer_id = await Network.player_joined
	while peer_id != multiplayer.get_unique_id():
		peer_id = await Network.player_joined
	
	print("connected!")
	
	SceneManager.change_scene("res://scenes/lobby/lobby.tscn")
	
	await SceneManager.changed_scene
	
	var lobby = SceneManager.get_current_scene()
	lobby.update_player_list()
	
	DisplayServer.window_set_title(str(get_tree().get_multiplayer().get_unique_id()))
	
	


func _on_connect_timer_timeout():
	pass # Replace with function body.

