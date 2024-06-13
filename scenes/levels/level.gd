class_name Level
extends Control


@export var camera_shaking_amount:int = 1
@export var camera_shaking_timer:float = 0.0
var previous_ammo_spawn_position:Vector2 = Vector2.ZERO

var total_players:Array[int] = []
var eliminated_players:Array[int] = []

@onready var entities_node:Node2D = $Entities
@onready var camera_node:Camera2D = $Camera2D
@onready var camera_start_position:Vector2 = camera_node.position
@onready var pickup_positions_node:Node2D = $PickupPositions
@onready var countdown_animation_player_node:AnimationPlayer = $LevelGUI/CountdownAnimationPlayer
@onready var damage_circle_node:ColorRect = $DamageCircle
@onready var player_spawn_positions_node:Node2D = $PlayerSpawnPositions

func _ready():
	Network.player_left.connect(player_left)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func player_left(peer_id:int):
	var player_nodes:Array = get_tree().get_nodes_in_group("player")
	for player_node in player_nodes:
		if player_node.peer_id == peer_id:
			
			if Network.is_online() and multiplayer.is_server():
				player_eliminated(player_node)
			
			player_node.queue_free()
			return


# called when all peers are ready
@rpc("authority", "call_local")
func _rpc_network_ready():
	_network_ready()


func attempt_ammo_pickup_spawn() -> void:
	
	if get_tree().get_nodes_in_group("ammo_pickup").size() > 1:
		return
	
	spawn_ammo_pickup()


func spawn_ammo_pickup() -> void:
	
	var entity_path:String = "res://scenes/ammo_pickup/ammo_pickup.tscn"
	var entity_name:String = str("ammo_pickup_e", Network.entity_counter)
	var parent_node_path:NodePath = entities_node.get_path()
	
	var possible_position_nodes:Array = pickup_positions_node.get_children()
	var ammo_position_node = possible_position_nodes.pick_random()
	
	if ammo_position_node.position == previous_ammo_spawn_position:
		possible_position_nodes.erase(ammo_position_node)
		ammo_position_node = possible_position_nodes.pick_random()
	
	var ammo_position = ammo_position_node.position
	
	
	
	var entity_data:Dictionary = {
		"position": ammo_position
	}
	
	previous_ammo_spawn_position = ammo_position
	
	Network.create_entity.rpc(entity_path, entity_name, parent_node_path, entity_data)


func spawn_health_pickup() -> void:
	
	var entity_path:String = "res://scenes/health_pickup/health_pickup.tscn"
	var entity_name:String = str("health_pickup_e", Network.entity_counter)
	var parent_node_path:NodePath = entities_node.get_path()
	
	var possible_position_nodes:Array = pickup_positions_node.get_children()
	var ammo_position_node = possible_position_nodes.pick_random()
	
	if ammo_position_node.position == previous_ammo_spawn_position:
		possible_position_nodes.erase(ammo_position_node)
		ammo_position_node = possible_position_nodes.pick_random()
	
	var ammo_position = ammo_position_node.position
	
	
	
	var entity_data:Dictionary = {
		"position": ammo_position
	}
	
	previous_ammo_spawn_position = ammo_position
	
	Network.create_entity.rpc(entity_path, entity_name, parent_node_path, entity_data)



func _process(delta):
	
	camera_node.rotation = lerp_angle(camera_node.rotation, 0.0, delta * 10)
	
	if camera_shaking_timer > 0.0:
		camera_shaking_timer = max(0.0, camera_shaking_timer - delta)
		
		
		camera_node.position = camera_start_position + Vector2(
			randi_range(-camera_shaking_amount, camera_shaking_amount),
			randi_range(-camera_shaking_amount, camera_shaking_amount)
		)
	else:
		camera_node.position = camera_start_position


func shake_camera(amount:int = 1, time:float = 2.0, rotation_amount:float = 0.0):
	camera_shaking_amount = amount
	camera_shaking_timer = time
	camera_node.rotation = rotation_amount


@rpc("authority", "call_local")
func spawn_players():
	
	for peer_id in Network.players:
		var player = Network.spawn_player(peer_id, entities_node, Vector2.ZERO, peer_id == multiplayer.get_unique_id())
		
		if player.is_local():
			
			print("im local!: ", peer_id)
			
			player.global_position = get_new_player_respawn_position()
			player.requested_quit_game.connect(leave_game)
			player.spawn_local_camera()
		
		total_players.append(player.peer_id)
		
		if Network.is_online() and multiplayer.is_server():
			player.eliminated.connect(player_eliminated)


func leave_game():
	Network.leave_game()


func player_eliminated(player_node:CharacterBody2D) -> void:
	eliminated_players.append(player_node.peer_id)
	
	check_win_conditions()


func check_win_conditions() -> void:
	if eliminated_players.size() == total_players.size() - 1:
		var winning_player_node = null
		
		for player_node in get_tree().get_nodes_in_group("player"):
			if player_node.peer_id in eliminated_players:
				continue
			
			winning_player_node = player_node
			break
		
		player_won(winning_player_node)


func player_won(winning_player_node:CharacterBody2D) -> void:
	
	MatchResults.winner = winning_player_node.peer_id
	SceneManager.server_change_scene("res://scenes/results_screen/results_screen.tscn")
	



func start_countdown() -> void:
	
	countdown_animation_player_node.play("countdown")
	shake_camera(2, 7, 0.0)
	
	await countdown_animation_player_node.animation_finished
	
	if Network.is_online() and multiplayer.is_server():
		spawn_players.rpc()
	


func get_new_player_respawn_position() -> Vector2:
	var possible_positions = player_spawn_positions_node.get_children()
	return possible_positions.pick_random().global_position



func _network_ready():
	start_countdown()



func _on_spawn_ammo_timer_timeout():
	if Network.is_online() and multiplayer.is_server():
		if randf() > 0.2:
			attempt_ammo_pickup_spawn()
		else:
			spawn_health_pickup()
