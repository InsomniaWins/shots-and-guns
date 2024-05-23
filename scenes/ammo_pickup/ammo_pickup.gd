extends Area2D



func _on_body_entered(body):
	if !multiplayer.is_server():
		return
	
	if !body.is_in_group("player"):
		return
	
	var player_node:CharacterBody2D = body
	player_node.ammo_manager_node.add_ammo(6)
	var peer_id:int = player_node.peer_id
	
	Network.free_entity.rpc(get_path())
	
	
