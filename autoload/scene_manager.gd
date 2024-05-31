extends Node

signal changed_scene(current_scene)
signal peer_changed_scene(peer_id:int, scene_path:String)
signal all_peers_changed_scene(scene_path:String)


var peers_not_finished_changing_scene:Array = []



@rpc("any_peer", "call_local")
func peer_finished_changing_scene(scene_path:String):
	var peer = multiplayer.get_remote_sender_id()
	
	if peers_not_finished_changing_scene.has(peer):
		peers_not_finished_changing_scene.erase(peer)
	
	peer_changed_scene.emit(peer, scene_path)
	
	if peers_not_finished_changing_scene.size() == 0:
		all_peers_changed_scene.emit()


# private func of change_scene used to defer func call
func _change_scene(next_scene_path:String, post_function:Callable) -> void:
	var next_scene:Node = load(next_scene_path).instantiate()
	var current_scene = get_current_scene()
	var current_scene_parent = get_current_scene_parent()
	var freed_scenes_parent = get_freed_scenes_parent()
	
	
	current_scene_parent.remove_child(current_scene)
	freed_scenes_parent.add_child(current_scene)
	current_scene.queue_free()
	
	current_scene_parent.add_child(next_scene)
	
	if !next_scene.is_node_ready():
		await next_scene.ready
	
	if !post_function.is_null():
		post_function.call()
	
	changed_scene.emit(next_scene)
	
	var is_online:bool = multiplayer.multiplayer_peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTED
	if is_online:
		peer_finished_changing_scene.rpc(get_current_scene().get_path())


@rpc("authority", "call_local")
func change_scene(next_scene_path:String, post_function:Callable = Callable()) -> void:
	_change_scene.call_deferred(next_scene_path, post_function)


# called by the server to change everyone's scene
func server_change_scene(next_scene_path:String) -> void:
	
	peers_not_finished_changing_scene = multiplayer.get_peers()
	change_scene.rpc(next_scene_path)
	
	await changed_scene
	
	if peers_not_finished_changing_scene.size() > 0:
		await all_peers_changed_scene
	
	var current_scene:Node = get_current_scene()
	if current_scene.has_method("_rpc_network_ready"):
		current_scene._rpc_network_ready.rpc()


func get_freed_scenes_parent() -> Node:
	return get_tree().current_scene.get_node("%FreedScenesParent")


func get_freed_scenes() -> Array[Node]:
	return get_freed_scenes_parent().get_children()


func get_current_scene_parent() -> Control:
	return get_tree().current_scene.get_node("%CurrentSceneParent")


func get_current_scene() -> Node:
	return get_current_scene_parent().get_child(0)
	


