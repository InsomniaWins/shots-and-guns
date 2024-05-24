extends Node

signal player_list_updated
signal player_joined(peer_id)
signal player_left(peer_id)
signal spawned_entity(entity_node_path:NodePath)

var my_information = create_new_player_info("default_username", HatManager.Hats.NONE, Color.WHITE)
var players:Dictionary = {}

var entity_counter:int = 0
var show_server_closed_message:bool = true

func _ready():
	multiplayer.server_disconnected.connect(server_disconnected)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)


func clear_player_list():
	players.clear()


func leave_game() -> void:
	show_server_closed_message = false
	multiplayer.multiplayer_peer.close()


func server_disconnected() -> void:
	clear_player_list()
	
	SceneManager.change_scene("res://scenes/titlescreen/titlescreen.tscn")
	
	
	if show_server_closed_message:
		await SceneManager.changed_scene
		
		var title_scene = SceneManager.get_current_scene()
		title_scene.show_message("Server Closed")
		
	else:
		show_server_closed_message = true


func peer_connected(_peer_id:int) -> void:
	pass


func peer_disconnected(peer_id:int) -> void:
	players.erase(peer_id)
	
	if multiplayer.get_unique_id() == 1:
		player_list_updated.emit()
		send_player_list_to_clients()
		
		_player_left(peer_id)
		_player_left.rpc(peer_id)


func create_new_player_info(username:String, hat:int, color:Color) -> Dictionary:
	return {
		"username": username,
		"hat": hat,
		"color": color
	}


func send_player_info_to_server(player_info:Dictionary) -> void:
	got_player_info_from_peer.rpc_id(1, player_info)


func kick_player(peer_id:int) -> void:
	get_tree().get_multiplayer().multiplayer_peer.disconnect_peer(peer_id)


@rpc("any_peer")
func got_player_info_from_peer(player_info:Dictionary) -> void:
	
	var sender:int = multiplayer.get_remote_sender_id()
	
	if !player_info.has("username") and !player_info.has("color") and !player_info.has("hat"):
		kick_player(sender)
		return
	
	if !players.has(sender):
		players[sender] = create_new_player_info(player_info["username"], player_info["hat"], player_info["color"])
	
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
	var my_peer_id:int = get_tree().get_multiplayer().multiplayer_peer.get_unique_id()
	
	if is_instance_valid(node):
		
		if node.has_method("_synchronize_unreliable"):
			node._synchronize_unreliable(node_data)
		
		elif should_print_error:
			printerr("peer ", my_peer_id, " could not sync node: ", node_path)
	
	elif should_print_error:
		printerr("peer ", my_peer_id, " could not find node: ", node_path)


func refuse_new_connections():
	multiplayer.multiplayer_peer.refuse_new_connections = true


func allow_new_connections():
	multiplayer.multiplayer_peer.refuse_new_connections = false


@rpc("any_peer")
func respawn_entities_for_peer():
	
	var sender:int = multiplayer.get_remote_sender_id()
	
	for entity in get_tree().get_nodes_in_group("entity"):
		var entity_path = entity.scene_file_path
		var entity_name = entity.name
		var parent_node_path = entity.get_parent().get_path()
		var data = entity.get_meta("entity_creation_data", {})
		
		create_entity.rpc_id(sender, entity_path, entity_name, parent_node_path, data)
	

@rpc("authority", "call_local")
func create_entity(entity_path:String, entity_name:String, parent_node_path:NodePath, data:Dictionary = {}):
	
	var predicted_node_path_string:String = str("/", parent_node_path.get_concatenated_names(), "/", entity_name)
	if get_node_or_null(predicted_node_path_string) != null:
		return
	
	var entity:Node = load(entity_path).instantiate()
	
	entity.name = entity_name
	
	if entity.has_method("set_entity_data"):
		entity.set_entity_data(data)
	
	entity.set_meta("entity_creation_data", data)
	
	get_node(parent_node_path).add_child(entity)
	
	entity_counter += 1
	
	spawned_entity.emit(entity.get_path())


@rpc("authority", "call_local")
func free_entity(entity_node_path:NodePath):
	
	var entity = get_node_or_null(entity_node_path)
	
	if is_instance_valid(entity):
		entity.queue_free()


func spawn_player(peer_id:int, parent_node:Node, spawn_position:Vector2, is_local:bool = false) -> Node:
	var player_node = preload("res://scenes/player/player.tscn").instantiate()
	
	player_node.local_player = is_local
	player_node.peer_id = peer_id
	player_node.name = str("player_", peer_id)
	player_node.position = spawn_position
	
	parent_node.add_child(player_node)
	player_node.set_username(Network.players[peer_id].username)
	player_node.set_color(Network.players[peer_id].color)
	player_node.set_hat(Network.players[peer_id].hat)
	
	return player_node


func is_online() -> bool:
	return multiplayer.multiplayer_peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTED



