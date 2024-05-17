extends CharacterBody2D

var peer_id:int = 1:
	set(id):
		peer_id = id
		
		if !is_inside_tree():
			await ready
		
		set_multiplayer_authority(peer_id)

var move_speed:float = 100.0

var moving:bool = false

var facing_direction:int = 1

@onready var sprite_node = $Sprite


func _process(delta):
	
	if is_online():
		if get_multiplayer_authority() == multiplayer.get_unique_id():
			Network.synchronize_node_unreliable.rpc(get_path(), {
				"position": position,
				"facing_direction": facing_direction,
				"moving": moving,
			})
	
	_handle_sprite_animations()


func is_online():
	return multiplayer.multiplayer_peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTED


func _synchronize_unreliable(data:Dictionary):
	position = data.position
	facing_direction = data.facing_direction
	moving = data.moving


func set_username(username:String) -> void:
	if !is_inside_tree():
		await ready
	
	$UsernameLabel.text = username


func _handle_sprite_animations() -> void:
	
	sprite_node.scale.x = facing_direction
	
	if moving:
		sprite_node.play("walk")
	else:
		sprite_node.play("idle")


func _physics_process(delta):
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		var move_direction = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")
			).normalized()
		
		velocity = move_direction * move_speed
		moving = velocity.length() > 0
		
		if velocity.x != 0.0:
			facing_direction = sign(velocity.x)
		
		move_and_slide()
