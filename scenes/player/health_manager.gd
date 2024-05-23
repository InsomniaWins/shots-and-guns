extends Node

var _health:int = 3
var _max_health:int = 3


@onready var status_bar_node:ColorRect = $"../GUI/StatusBar"
@onready var player_node = $".."

func _ready():
	status_bar_node.update_health_indicator()



func _process(delta):
	if multiplayer.is_server():
		if player_node.is_online():
			Network.synchronize_node_unreliable.rpc(get_path(), {
				"health": _health
			})


func _synchronize_unreliable(data:Dictionary):
	var previous_health = _health
	_health = data.health
	if _health != previous_health:
		status_bar_node.update_health_indicator()



func take_damage(amount:int = 1) -> void:
	_health = max(0, _health - amount)
	status_bar_node.update_health_indicator()


func heal(amount:int = 1) -> void:
	_health = min(_max_health, _health + amount)
	status_bar_node.update_health_indicator()


func get_health() -> int:
	return _health


func get_max_health() -> int:
	return _max_health
