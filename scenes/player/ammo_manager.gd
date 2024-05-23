extends Node

var _max_ammo:int = 6
var _ammo:int = 3


@onready var status_bar_node:ColorRect = $"../GUI/StatusBar"
@onready var player_node:CharacterBody2D = $".."


func _ready():
	status_bar_node.update_ammo_indicator()


func _process(delta):
	if multiplayer.is_server():
		if player_node.is_online():
			Network.synchronize_node_unreliable.rpc(get_path(), {
				"ammo": _ammo
			})


func _synchronize_unreliable(data:Dictionary):
	var previous_ammo = _ammo
	_ammo = data.ammo
	if _ammo != previous_ammo:
		status_bar_node.update_ammo_indicator()


func remove_ammo(amount:int = 1) -> void:
	_ammo = max(0, _ammo - 1)
	status_bar_node.update_ammo_indicator()


func add_ammo(amount:int = 1) -> void:
	_ammo = min(_max_ammo, _ammo + amount)
	status_bar_node.update_ammo_indicator()


func get_ammo() -> int:
	return _ammo


func get_max_ammo() -> int:
	return _max_ammo
