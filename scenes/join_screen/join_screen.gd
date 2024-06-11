extends Control

var current_ip:String = Settings.default_ip
var current_port:String = str(Settings.default_port)

@onready var main_menu_node = $MainMenu
@onready var status_label_node:Label = $StatusLabel
@onready var connect_timer_node:Timer = $ConnectTimer
@onready var connecting_label_animation_player_node:AnimationPlayer = $ConnectingLabelAnimationPlayer
@onready var port_edit_controller_input_node := $PortEditControllerInput
@onready var ip_edit_controller_input_node := $IpEditControllerInput
@onready var ip_edit_node := $IpEdit
@onready var port_edit_node := $PortEdit

func _ready():
	Network.player_joined.connect(player_joined)
	
	current_port = str(Settings.default_port)
	port_edit_node.text = current_port
	
	current_ip = str(Settings.default_ip)
	ip_edit_node.text = current_ip

func _process(delta):
	status_label_node.modulate.a = lerp(status_label_node.modulate.a, 0.0, delta)


func _join_server(ip:String, port:int, username:String) -> void:
	
	var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var client_creation_result:int = peer.create_client(ip, port)
	
	if client_creation_result != OK:
		status_label_node.text = str("Failed to make client peer: ", client_creation_result)
		status_label_node.modulate = Color.RED
		
		main_menu_node.activate()
		port_edit_node.mouse_filter = MOUSE_FILTER_STOP
		ip_edit_node.mouse_filter = MOUSE_FILTER_STOP
		return
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		status_label_node.text = "Failed to join server!"
		status_label_node.modulate = Color.RED
		
		main_menu_node.activate()
		port_edit_node.mouse_filter = MOUSE_FILTER_STOP
		ip_edit_node.mouse_filter = MOUSE_FILTER_STOP
		return
	
	multiplayer.multiplayer_peer = peer
	
	main_menu_node.deactivate()
	port_edit_node.mouse_filter = MOUSE_FILTER_IGNORE
	ip_edit_node.mouse_filter = MOUSE_FILTER_IGNORE
	connecting_label_animation_player_node.play("connecting")
	
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
		
		main_menu_node.activate()
		port_edit_node.mouse_filter = MOUSE_FILTER_STOP
		ip_edit_node.mouse_filter = MOUSE_FILTER_STOP
		
		peer.close()
		connecting_label_animation_player_node.play("RESET")
		return
		
	elif peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		status_label_node.text = "Failed to join server!"
		status_label_node.modulate = Color.RED
		connecting_label_animation_player_node.play("RESET")
		port_edit_node.mouse_filter = MOUSE_FILTER_STOP
		ip_edit_node.mouse_filter = MOUSE_FILTER_STOP
		main_menu_node.activate()
		return
	
	Network.players[peer.get_unique_id()] = Network.create_new_player_info(
		Network.my_information.username,
		Network.my_information.hat,
		Network.my_information.color
	)
	
	
	Network.send_player_info_to_server(Network.my_information)
	
	$ServerAlreadyStartedTimer.start()



func player_joined(peer_id):
	
	connecting_label_animation_player_node.play("RESET")
	
	while peer_id != multiplayer.get_unique_id():
		peer_id = await Network.player_joined
	
	SceneManager.change_scene("res://scenes/lobby/lobby.tscn")
	
	await SceneManager.changed_scene
	
	var lobby = SceneManager.get_current_scene()
	lobby.update_player_list()



func _on_main_menu_menu_selected():
	var button_name = main_menu_node.button_names[main_menu_node.selected_button_index]
	
	match button_name:
		"EDIT IP":
			main_menu_node.deactivate()
			ip_edit_node.grab_focus()
			ip_edit_node.caret_column = ip_edit_node.text.length()
		"EDIT PORT":
			main_menu_node.deactivate()
			port_edit_node.grab_focus()
			port_edit_node.caret_column = port_edit_node.text.length()
		"JOIN":
			main_menu_node.deactivate()
			_join_server(current_ip, current_port.to_int(), Network.my_information.username)
		"BACK":
			SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")


func _on_server_already_started_timer_timeout():
	status_label_node.text = "Failed to join server!\nGame likely already started!"
	status_label_node.modulate = Color.RED
	main_menu_node.activate()
	connecting_label_animation_player_node.play("RESET")


func _on_port_edit_text_submitted(new_text):
	current_port = str(new_text.to_int())
	port_edit_node.release_focus()
	main_menu_node.activate()
	
	Settings.default_port = current_port.to_int()
	Settings.save_settings()


func _on_ip_edit_text_submitted(new_text):
	if new_text.is_empty():
		return
	
	current_ip = new_text
	ip_edit_node.release_focus()
	main_menu_node.activate()
	
	Settings.default_ip = current_ip
	Settings.save_settings()
