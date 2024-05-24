extends Control

var current_ip:String = "LOCALHOST"
var current_port:String = "25565"
var editing_ip = false
var editing_port = false

@onready var main_menu_node = $MainMenu
@onready var current_ip_label_node = $ConnectionInfo/IPLabel
@onready var current_port_label_node = $ConnectionInfo/PortLabel
@onready var status_label_node:Label = $StatusLabel
@onready var connect_timer_node:Timer = $ConnectTimer
@onready var connecting_label_animation_player_node:AnimationPlayer = $ConnectingLabelAnimationPlayer

func _ready():
	update_current_information()

func _process(delta):
	status_label_node.modulate.a = lerp(status_label_node.modulate.a, 0.0, delta)


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
	
	main_menu_node.deactivate()
	connecting_label_animation_player_node.play("connecting")
	
	const TIMEOUT:int = 10
	for i in TIMEOUT:
		
		print("connecting . . . ", i)
		
		connect_timer_node.start()
		await connect_timer_node.timeout
		
		if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING:
			break
	
	connecting_label_animation_player_node.play("RESET")
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		status_label_node.text = str("Connection took longer than ", TIMEOUT, " seconds, timed-out!")
		status_label_node.modulate = Color.RED
		
		main_menu_node.activate()
		
		peer.close()
		return
		
	elif peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		status_label_node.text = "Failed to join server!"
		status_label_node.modulate = Color.RED
		return
	
	Network.players[peer.get_unique_id()] = Network.create_new_player_info(
		Network.my_information.username,
		Network.my_information.hat,
		Network.my_information.color
	)
	
	Network.send_player_info_to_server(Network.my_information)
	
	var peer_id = await Network.player_joined
	while peer_id != multiplayer.get_unique_id():
		peer_id = await Network.player_joined
	
	SceneManager.change_scene("res://scenes/lobby/lobby.tscn")
	
	await SceneManager.changed_scene
	
	var lobby = SceneManager.get_current_scene()
	lobby.update_player_list()
	
	DisplayServer.window_set_title(str(get_tree().get_multiplayer().get_unique_id()))
	
	


func _input(event):
	if event is InputEventKey:
		if event.pressed and !event.echo:
			var key_string:String = event.as_text_keycode()
			
			if key_string.length() > 1:
				
				if key_string == "Enter" or key_string == "Escape" or key_string == "Enter":
					editing_port = false
					editing_ip = false
					main_menu_node.activate()
					return
				elif key_string == "Backspace":
					if editing_port:
						current_port = current_port.substr(0, current_port.length()-1)
					elif editing_ip:
						current_ip = current_ip.substr(0, current_ip.length()-1)
					update_current_information()
					return
				elif key_string == "Period":
					key_string = "."
				else:
					return
			
			if editing_ip:
				current_ip = current_ip + key_string
			elif editing_port:
				current_port = str(current_port, key_string.to_int())
			update_current_information()


func update_current_information() -> void:
	current_ip_label_node.text = "IP: " + current_ip
	current_port_label_node.text = "PORT: " + current_port


func _on_main_menu_menu_selected():
	var button_name = main_menu_node.button_names[main_menu_node.selected_button_index]
	
	match button_name:
		"EDIT IP":
			editing_ip = true
			main_menu_node.deactivate()
		"EDIT PORT":
			editing_port = true
			main_menu_node.deactivate()
		"JOIN":
			main_menu_node.deactivate()
			_join_server(current_ip, current_port.to_int(), Network.my_information.username)
		"BACK":
			SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")
