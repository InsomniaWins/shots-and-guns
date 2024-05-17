extends Node

signal player_list_updated
signal player_joined(peer_id)
signal player_left(peer_id)

var players:Dictionary = {}


func _ready():
	multiplayer.server_disconnected.connect(server_disconnected)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)


func clear_player_list():
	players.clear()


func server_disconnected() -> void:
	clear_player_list()
	
	SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")
	
	await SceneManager.changed_scene
	
	var title_scene = SceneManager.get_current_scene()
	title_scene.show_message("Server Closed")


func peer_connected(_peer_id:int) -> void:
	pass


func peer_disconnected(peer_id:int) -> void:
	players.erase(peer_id)
	
	if multiplayer.get_unique_id() == 1:
		player_list_updated.emit()
		send_player_list_to_clients()
		
		_player_left(peer_id)
		_player_left.rpc(peer_id)


func create_new_player_info() -> Dictionary:
	return {
		"username": "?"
	}


func send_player_info_to_server(player_info:Dictionary) -> void:
	got_player_info_from_peer.rpc_id(1, player_info)


@rpc("any_peer")
func got_player_info_from_peer(player_info:Dictionary) -> void:
	if !player_info.has("username"):
		return
	
	var sender:int = multiplayer.get_remote_sender_id()
	
	if !players.has(sender):
		players[sender] = create_new_player_info()
	
	players[sender]["username"] = player_info["username"]
	
	send_player_list_to_clients()
	player_list_updated.emit()
	
	_player_joined(sender)
	_player_joined.rpc(sender)


@rpc("authority")
func _player_joined(peer_id:int) -> void:
	player_joined.emit(peer_id)

@rpc("authority")
func _player_left(peer_id:int) -> void:
	player_left.emit(peer_id)

func send_player_list_to_clients() -> void:
	got_player_list_from_server.rpc(players)


@rpc("authority")
func got_player_list_from_server(_players:Dictionary) -> void:
	players = _players
	player_list_updated.emit()


@rpc("any_peer", "unreliable")
func synchronize_node_unreliable(node_path:String, node_data:Dictionary, should_print_error:bool=false):
	
	var node = get_node_or_null(node_path)
	
	if is_instance_valid(node):
		if node.has_method("_synchronize_unreliable"):
			node._synchronize_unreliable(node_data)
		elif should_print_error:
			printerr("peer ", get_tree().get_multiplayer().multiplayer_peer.get_unique_id(), " could not sync node: ", node_path)
	elif should_print_error:
		printerr("peer ", get_tree().get_multiplayer().multiplayer_peer.get_unique_id(), " could not find node: ", node_path)



