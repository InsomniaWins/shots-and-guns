extends CharacterBody2D

var peer_id:int = 1:
	set(id):
		peer_id = id
		
		if !is_inside_tree():
			await ready
		
		set_multiplayer_authority(peer_id)

var local_player:bool = false
var move_speed:float = 100.0
var moving:bool = false
var facing_direction:int = 1
var camera_node:Camera2D = null
var aim_direction:Vector2 = Vector2.RIGHT

@onready var animation_player_node = $AnimationPlayer
@onready var facing_scaler_node = $FacingScaler
@onready var aim_arrow_rotation_node = $AimArrowRotation


func _ready():
	aim_arrow_rotation_node.visible = is_local()


func _process(_delta):
	
	if is_local():
		if is_online():
			Network.synchronize_node_unreliable.rpc(get_path(), {
				"position": position,
				"facing_direction": facing_direction,
				"moving": moving,
			})
		
		aim_direction = Vector2(
			Input.get_axis("aim_left", "aim_right"),
			Input.get_axis("aim_up", "aim_down")
		)
		aim_arrow_rotation_node.rotation = aim_direction.angle()
		
	
	_handle_sprite_animations()


func is_local():
	return local_player


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

func set_color(color:Color) -> void:
	if !is_inside_tree():
		await ready
	$FacingScaler/Sprite.material = $FacingScaler/Sprite.material.duplicate()
	$FacingScaler/Sprite.material.set_shader_parameter("tint_color", color)
	var outline_color = Color.WHITE - color
	outline_color.a = 1.0
	$FacingScaler/Sprite.material.set_shader_parameter("color", outline_color)
	

func set_hat(hat:int) -> void:
	if !is_inside_tree():
		await ready
	
	$FacingScaler/Sprite/Hat.texture = HatManager.get_hat_texture(hat)


func _handle_sprite_animations() -> void:
	
	facing_scaler_node.scale.x = facing_direction
	
	if moving:
		if animation_player_node.current_animation != "walk":
			animation_player_node.play("walk")
	else:
		if animation_player_node.current_animation != "idle":
			animation_player_node.play("idle")


func _physics_process(_delta):
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
