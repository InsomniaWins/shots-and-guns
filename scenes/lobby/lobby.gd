extends Control


var pickup_locations:Array[Dictionary] = [
	{
		"index": 0,
		"pickup": null
	},
	{
		"index": 1,
		"pickup": null
	},
	{
		"index": 2,
		"pickup": null
	},
	{
		"index": 3,
		"pickup": null
	}
]
var camera_shaking_timer:float = 0.0
var camera_shaking_amount:int = 0

@onready var spawn_pickup_timer_node:Timer = $SpawnPickupTimer
@onready var margin_container_node:MarginContainer = $MarginContainer
@onready var player_list_node:VBoxContainer = margin_container_node.get_node("PlayerList")
@onready var outline_node:NinePatchRect = $Outline
@onready var players_node = $Players
@onready var player_spawn_point_node = $PlayerSpawnPoint
@onready var start_button_node = $CanvasLayer/StartButton
@onready var pickup_spawn_positions_node = $PickupSpawnPositions
@onready var camera_node = $Camera2D
@onready var camera_start_position = camera_node.global_position

func _ready():
	Network.player_list_updated.connect(_players_dictionary_updated)
	
	for player_id in Network.players:
		spawn_player(player_id)
	
	Network.player_joined.connect(server_on_player_joined)
	Network.player_left.connect(server_on_player_left)
	
	if multiplayer.is_server():
		spawn_pickup_timer_node.start()
		start_button_node.visible = true
		Network.allow_new_connections()
	else:
		start_button_node.visible = false


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


func server_on_player_joined(peer_id):
	spawn_player(peer_id)

func server_on_player_left(peer_id):
	despawn_player(peer_id)

func get_new_player_respawn_position() -> Vector2:
	return player_spawn_point_node.global_position


func despawn_player(peer_id:int) -> void:
	var player_node_name:String = str("player_", peer_id)
	if !players_node.has_node(player_node_name):
		return
	
	var player_node = players_node.get_node(player_node_name)
	
	player_node.queue_free()


func spawn_player(peer_id:int) -> void:
	var player_node = Network.spawn_player(peer_id, players_node, player_spawn_point_node.position, peer_id == multiplayer.get_unique_id())
	player_node.eliminated.connect(player_eliminated)


func player_eliminated(player_node:CharacterBody2D) -> void:
	
	if !(Network.is_online() and multiplayer.is_server()):
		return
	
	player_node.health_manager_node.heal(player_node.health_manager_node.get_max_health())
	player_node.health_manager_node.respawn.rpc(player_node.health_manager_node.get_health())


func shake_camera(amount:int = 1, time:float = 2.0, rotation_amount:float = 0.0):
	camera_shaking_amount = amount
	camera_shaking_timer = time
	camera_node.rotation = rotation_amount



func _players_dictionary_updated():
	update_player_list()


func update_player_list() -> void:
	
	for child in player_list_node.get_children():
		child.queue_free()
	
	for peer_id in Network.players:
		var player_info = Network.players[peer_id]
		
		var label:Label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		if peer_id == 1:
			label.text = "* "
		
		label.text = label.text + player_info["username"]
		label.add_theme_font_override("font", preload("res://fonts/normal/normal.png"))
		
		player_list_node.add_child(label)




func _on_margin_container_resized():
	
	if margin_container_node == null:
		margin_container_node = get_node("MarginContainer")
	if outline_node == null:
		outline_node = get_node("Outline")
	
	outline_node.position = margin_container_node.position - Vector2(4,4)
	outline_node.size = margin_container_node.size + Vector2(8,8)



func _on_start_button_pressed():
	
	Network.refuse_new_connections()
	
	var next_scene_path:String = "res://scenes/levels/level.tscn"
	SceneManager.server_change_scene(next_scene_path)
	



func _on_leave_button_pressed():
	
	Network.leave_game()


# called on server only!
func attempt_pickup_spawn() -> void:
	
	if get_tree().get_nodes_in_group("pickup").size() >= 4:
		return
	
	var possible_spawn_positions:Array = pickup_locations.duplicate(true)
	var spawn_position = possible_spawn_positions.pick_random()
	
	if spawn_position.pickup != null:
		while get_node_or_null(spawn_position.pickup) != null:
			
			possible_spawn_positions.remove_at(possible_spawn_positions.find(spawn_position))
			spawn_position = possible_spawn_positions.pick_random()
			
			if spawn_position == null:
				return
			
			if spawn_position.pickup == null:
				break
	
	var spawn_position_node = pickup_spawn_positions_node.get_child(spawn_position.index)
	
	var entity_name = str("pickup_e", Network.entity_counter)
	
	Network.create_entity.rpc(
		["res://scenes/ammo_pickup/ammo_pickup.tscn", "res://scenes/health_pickup/health_pickup.tscn"].pick_random(),
		entity_name,
		players_node.get_path(),
		{
			"position": spawn_position_node.global_position
		}
		)
	
	var entity_node_path:String = "/" + players_node.get_path().get_concatenated_names() + str("/", entity_name)
	pickup_locations[spawn_position.index].pickup = entity_node_path

func _on_spawn_pickup_timer_timeout():
	if !(Network.is_online() and multiplayer.is_server()):
		return
	
	attempt_pickup_spawn()
