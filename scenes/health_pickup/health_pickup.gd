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
	
	player_node.health_manager_node.heal(1)
	var peer_id:int = player_node.peer_id
	
	Network.free_entity.rpc(get_path())
