extends CharacterBody2D

signal requested_start_game
signal requested_quit_game

signal respawned
signal eliminated(player_node)

const BulletLine = preload("res://scenes/bullet_line/bullet_line.tscn")
const PauseMenu = preload("res://scenes/pause_menu/pause_menu.tscn")

const WALK_SPEED:float = 100.0
const DASH_SPEED:float = 250.0

var peer_id:int = 1:
	set(id):
		peer_id = id
		
		if !is_inside_tree():
			await ready
		
		set_multiplayer_authority(peer_id)

var respawning:bool = false
var local_player:bool = false
var move_speed:float = WALK_SPEED
var moving:bool = false
var facing_direction:int = 1
var camera_node:Camera2D = null
var aim_direction:Vector2 = Vector2.RIGHT
var i_time:float = 0.0
var wide_spread:bool = false
var pause_menu_node:CanvasLayer = null

@onready var gui_node = $GUI
@onready var animation_player_node = $AnimationPlayer
@onready var facing_scaler_node = $FacingScaler
@onready var aim_arrow_rotation_node = $AimArrowRotation
@onready var dash_timer_node = $DashTimer
@onready var dash_particles_node = $DashParticles
@onready var stamina_bar_node = $GUI/StatusBar/StaminaBar
@onready var ammo_manager_node = $AmmoManager
@onready var health_manager_node = $HealthManager
@onready var shoot_timer_node:Timer = $ShootTimer
@onready var invincible_particle_emitter_node:GPUParticles2D = $InvincibleParticles
@onready var shotgun_audio_player_node:AudioStreamPlayer2D = $ShotgunSound
@onready var gain_invincibility_audio_player_node:AudioStreamPlayer2D = $InvincibilitySound
@onready var heal_audio_player_node:AudioStreamPlayer2D = $HealSound

func _ready():
	aim_arrow_rotation_node.visible = is_local()
	gui_node.visible = is_local()

@rpc("authority", "call_local")
func emit_dash_particles():
	dash_particles_node.emitting = true


func is_respawning() -> bool:
	return respawning


func is_paused() -> bool:
	return is_instance_valid(pause_menu_node)


func _pause() -> void:
	
	if !is_local():
		return
	
	pause_menu_node = PauseMenu.instantiate()
	pause_menu_node.resume_selected.connect(_on_pause_menu_resume_selected)
	pause_menu_node.quit_selected.connect(_on_pause_menu_quit_selected)
	pause_menu_node.start_game_selected.connect(_on_pause_menu_start_game_selected)
	add_child(pause_menu_node)
	


func _process(delta):
	
	if Input.is_action_just_pressed("pause"):
		if !is_paused():
			_pause()
	
	i_time = max(i_time - delta, 0.0)
	invincible_particle_emitter_node.emitting = i_time > 0.0
	
	if is_local() and !is_paused():
		
		if !is_respawning():
			move_speed = move_toward(move_speed, WALK_SPEED, delta * 150)
			if Input.is_action_just_pressed("dash"):
				if dash_timer_node.is_stopped():
					emit_dash_particles.rpc()
					move_speed = DASH_SPEED
					dash_timer_node.start()
			
			
			var axis_vector:Vector2
			
			if Settings.input_mode == Settings.InputMode.CONTROLLER:
				# key aiming
				axis_vector = Vector2(
					Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
					Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
				)
			else:
				# mouse aiming
				axis_vector = get_global_mouse_position() - global_position
			
			if axis_vector.x != 0 or axis_vector.y != 0:
				aim_direction = axis_vector
			aim_arrow_rotation_node.rotation = aim_direction.angle()
			
			
			if Input.is_action_just_pressed("shoot"):
				if shoot_timer_node.time_left <= 0.0:
					shoot.rpc(aim_direction)
					shoot_timer_node.start()
					
		
		stamina_bar_node.value = 1.0 - (dash_timer_node.time_left / dash_timer_node.wait_time)
		
		if is_online():
			Network.synchronize_node_unreliable.rpc(get_path(), {
				"position": position,
				"facing_direction": facing_direction,
				"moving": moving,
			})
	
	_handle_sprite_animations()


@rpc("authority", "call_local")
func shoot(direction:Vector2):
	
	if ammo_manager_node.get_ammo() <= 0:
		return
	
	if multiplayer.get_remote_sender_id() == peer_id:
		gui_node.flash()
	
	shotgun_audio_player_node.play()
	
	var shoot_directions = [
		direction.rotated(-PI * 0.1),
		direction,
		direction.rotated(PI * 0.1)
		]
	
	for shoot_direction in shoot_directions:
		
		shoot_direction = shoot_direction.normalized()
		
		# shoot effect
		var bullet_line = BulletLine.instantiate()
		bullet_line.add_point(position)
		bullet_line.add_point(position + shoot_direction * 100)
		
		get_parent().add_child(bullet_line)
	
	var current_scene = SceneManager.get_current_scene()
	if current_scene.has_method("shake_camera"):
		current_scene.shake_camera(3, 0.1, PI * 0.0125)
	
	
	if multiplayer.is_server():
		
		if ammo_manager_node.get_ammo() > 0:
			ammo_manager_node.remove_ammo()
			
			
			if wide_spread:
				wide_spread = false
				shoot_directions = [
					direction.rotated(-PI * 0.2),
					direction,
					direction.rotated(PI * 0.2)
					]
			
			for shoot_direction in shoot_directions:
				create_bullet_entity(shoot_direction.normalized())
	


# called on server ONLY
func create_bullet_entity(direction:Vector2):
	Network.create_entity.rpc("res://scenes/bullet/bullet.tscn", str("bullet_e", Network.entity_counter), get_parent().get_path(), {
		"position": position + direction * 5,
		"rotation": direction.angle(),
		"shooter": peer_id
	})


func is_local():
	return local_player


func is_online():
	return Network.is_online()


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
	
	var body_color_average:float = (color.r + color.g + color.b) / 3.0
	var outline_color = Color.WHITE if body_color_average <= 0.5 else Color.BLACK
	
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
	if is_local() and !is_respawning() and !is_paused():
		var move_direction = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")
			).normalized()
		
		velocity = move_direction * move_speed
		moving = velocity.length() > 0
		
		if velocity.x != 0.0:
			facing_direction = sign(velocity.x)
		
		move_and_slide()


@rpc("any_peer", "call_local")
func set_invincible(time:float) -> void:
	
	if time > 0.0:
		gain_invincibility_audio_player_node.play()
	
	if multiplayer.get_remote_sender_id() != 1:
		return
	
	i_time = time


func _on_dash_timer_timeout():
	move_speed = WALK_SPEED


func _on_hit_box_damaged(amount):
	health_manager_node.take_damage(amount)


func _on_pause_menu_resume_selected():
	pause_menu_node.queue_free()


func _on_pause_menu_quit_selected():
	requested_quit_game.emit()


func _on_pause_menu_start_game_selected():
	requested_start_game.emit()
