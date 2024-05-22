class_name Level
extends Control

@onready var players_node:Node2D = $Players

# called when all peers are ready
@rpc("authority", "call_local")
func _rpc_network_ready():
	_network_ready()


func _network_ready():
	
	for peer_id in Network.players:
		Network.spawn_player(peer_id, players_node, Vector2.ZERO, peer_id == multiplayer.get_unique_id())
	
	
