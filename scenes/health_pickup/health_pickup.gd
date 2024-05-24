extends Area2D


func set_entity_data(data:Dictionary) -> void:
	
	await ready
	
	global_position = data.position
	
	$SpawnSound.play()


func _on_body_entered(body):
	if !multiplayer.is_server():
		return
	
	if !body.is_in_group("player"):
		return
	
	var player_node:CharacterBody2D = body
	
	if player_node.health_manager_node.get_health() >= player_node.health_manager_node.get_max_health():
		player_node.set_invincible.rpc(5.0)
	else:
		player_node.health_manager_node.play_heal_sound.rpc()
	
	player_node.health_manager_node.heal(1)
	
	Network.free_entity.rpc(get_path())
