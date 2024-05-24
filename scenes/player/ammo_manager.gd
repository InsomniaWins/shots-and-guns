extends Node

var _max_ammo:int = 6
var _ammo:int = 0


@onready var status_bar_node:ColorRect = $"../GUI/StatusBar"
@onready var player_node:CharacterBody2D = $".."
@onready var ammo_pickup_audio_player_node:AudioStreamPlayer2D = $"../PickupAmmo"


func _ready():
	status_bar_node.update_ammo_indicator()


func _process(_delta):
	if Network.is_online() and multiplayer.is_server():
		if player_node.is_online():
			Network.synchronize_node_unreliable.rpc(get_path(), {
				"ammo": _ammo
			})


func _synchronize_unreliable(data:Dictionary):
	var previous_ammo = _ammo
	_ammo = data.ammo
	if _ammo != previous_ammo:
		status_bar_node.update_ammo_indicator()


@rpc("any_peer", "call_local")
func play_ammo_pickup_sound() -> void:
	
	if multiplayer.get_remote_sender_id() != 1:
		return
	
	ammo_pickup_audio_player_node.play()

func remove_ammo(amount:int = 1) -> void:
	_ammo = max(0, _ammo - amount)
	status_bar_node.update_ammo_indicator()


func add_ammo(amount:int = 1) -> void:
	_ammo = min(_max_ammo, _ammo + amount)
	status_bar_node.update_ammo_indicator()


func get_ammo() -> int:
	return _ammo


func get_max_ammo() -> int:
	return _max_ammo
