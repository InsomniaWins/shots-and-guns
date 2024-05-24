extends Area2D


func set_entity_data(data:Dictionary) -> void:
	
	await ready
	
	global_position = data.position


func _on_body_entered(body):
	if !multiplayer.is_server():
		return
	
	if !body.is_in_group("player"):
		return
	
	var player_node:CharacterBody2D = body
	
	if player_node.ammo_manager_node.get_ammo() == player_node.ammo_manager_node.get_max_ammo():
		return
	
	player_node.ammo_manager_node.add_ammo(6)
	var peer_id:int = player_node.peer_id
	
	Network.free_entity.rpc(get_path())
	
	
