class_name Level
extends Control

var camera_shaking_amount:int = 1
var camera_shaking_timer:float = 0.0

@onready var entities_node:Node2D = $Entities
@onready var camera_node:Camera2D = $Camera2D
@onready var camera_start_position:Vector2 = camera_node.position


func _ready():
	Network.player_left.connect(player_left)


func player_left(peer_id:int):
	var player_nodes:Array = get_tree().get_nodes_in_group("player")
	for player_node in player_nodes:
		if player_node.peer_id == peer_id:
			player_node.queue_free()
			return


# called when all peers are ready
@rpc("authority", "call_local")
func _rpc_network_ready():
	_network_ready()


func _process(delta):
	
	if camera_shaking_timer > 0.0:
		camera_shaking_timer = max(0.0, camera_shaking_timer - delta)
		
		camera_node.position = camera_start_position + Vector2(
			randi_range(-camera_shaking_amount, camera_shaking_amount),
			randi_range(-camera_shaking_amount, camera_shaking_amount)
		)
	else:
		camera_node.position = camera_start_position
	
	if Input.is_action_just_pressed("ui_cancel"):
		if multiplayer.is_server():
			SceneManager.change_scene.rpc("res://scenes/lobby/lobby.tscn")

func shake_camera(amount:int = 1, time:float = 2.0):
	camera_shaking_amount = amount
	camera_shaking_timer = time

func _network_ready():
	
	for peer_id in Network.players:
		var player = Network.spawn_player(peer_id, entities_node, Vector2.ZERO, peer_id == multiplayer.get_unique_id())
	
