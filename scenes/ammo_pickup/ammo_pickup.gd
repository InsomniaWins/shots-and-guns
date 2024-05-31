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
	
	if player_node.ammo_manager_node.get_ammo() == player_node.ammo_manager_node.get_max_ammo():
		player_node.wide_spread = true
	
	if player_node.ammo_manager_node.get_ammo() == 0:
		player_node.ammo_manager_node.add_ammo(6)
	else:
		player_node.ammo_manager_node.add_ammo(1)
	
	player_node.ammo_manager_node.play_ammo_pickup_sound.rpc()
	
	Network.free_entity.rpc(get_path())
	
	
