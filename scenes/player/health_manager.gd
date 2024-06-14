extends Node

var _health:int = 3
var _max_health:int = 3


@onready var status_bar_node:ColorRect = $"../GUI/StatusBar"
@onready var player_node = $".."
@onready var gain_invincibility_audio_player_node:AudioStreamPlayer2D = $"../InvincibilitySound"
@onready var lose_audio_player_node:AudioStreamPlayer = $"../LoseSound"

func _ready():
	status_bar_node.update_health_indicator()



func _process(_delta):
	if Network.is_online() and multiplayer.is_server():
		if player_node.is_online():
			Network.synchronize_node_unreliable.rpc(get_path(), {
				"health": _health
			})


func _synchronize_unreliable(data:Dictionary):
	var previous_health = _health
	_health = data.health
	if _health != previous_health:
		status_bar_node.update_health_indicator()


func get_new_respawn_position() -> Vector2:
	
	var current_scene = SceneManager.get_current_scene()
	if current_scene.has_method("get_new_player_respawn_position"):
		return current_scene.get_new_player_respawn_position()
	
	return Vector2.ZERO


@rpc("any_peer", "call_local")
func respawn(new_health):
	
	var sender:int = multiplayer.get_remote_sender_id()
	
	if sender != 1:
		return
	
	player_node.visible = false
	player_node.respawning = true
	
	player_node.position = Vector2(-10000, -10000)
	
	_health = new_health
	status_bar_node.update_health_indicator()
	
	if _health <= 0:
		
		if player_node.is_local():
			lose_audio_player_node.play()
		
		player_node.eliminated.emit(player_node)
		return
	
	await get_tree().create_timer(2).timeout
	
	if player_node.is_local():
		player_node.global_position = get_new_respawn_position()
	
	player_node.respawning = false
	player_node.respawned.emit()
	player_node.visible = true
	player_node.i_time = 2
	gain_invincibility_audio_player_node.play()


@rpc("any_peer", "call_local")
func play_heal_sound() -> void:
	
	if multiplayer.get_remote_sender_id() != 1:
		return
	
	player_node.heal_audio_player_node.play()





func take_damage(amount:int = 1) -> void:
	
	if player_node.i_time > 0.0:
		return
	
	if player_node.is_respawning():
		return
	
	_health = max(0, _health - amount)
	status_bar_node.update_health_indicator()
	
	
	# create dead body
	Network.create_entity.rpc(
		"res://scenes/dead_body/dead_body.tscn",
		str("dead_body_e", Network.entity_counter),
		player_node.get_parent().get_path(),
		{
			"position": player_node.global_position.floor() + Vector2(0, 6),
			"color": Network.players[player_node.peer_id].color,
			"hat": Network.players[player_node.peer_id].hat
		}
		
		)
	
	
	respawn.rpc(_health)


func heal(amount:int = 1) -> void:
	_health = min(_max_health, _health + amount)
	status_bar_node.update_health_indicator()


func get_health() -> int:
	return _health


func get_max_health() -> int:
	return _max_health
