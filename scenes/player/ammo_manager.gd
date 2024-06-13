extends Node

const _MAX_BOOST_AMOUNT:int = 4
const EVIL_LAUGH_SOUND:AudioStream = preload("res://sounds/evil_laugh.ogg")
const OVER_LIMIT_LAUGH_SOUND:AudioStream = preload("res://sounds/over_limit_laugh.ogg")

var _max_bonus_ammo:int = 6
var _bonus_ammo:int = 0
var _max_ammo:int = 6
var _ammo:int = 0
var _boost_amount:int = 0

@onready var status_bar_node:ColorRect = $"../GUI/StatusBar"
@onready var player_node:CharacterBody2D = $".."
@onready var ammo_pickup_audio_player_node:AudioStreamPlayer2D = $"../PickupAmmo"
@onready var rage_meter_node := $"../GUI/RageMeter"

func _ready():
	status_bar_node.update_ammo_indicator()


func _process(delta):
	if Network.is_online() and multiplayer.is_server():
		if player_node.is_online():
			Network.synchronize_node_unreliable.rpc(get_path(), {
				"ammo": _ammo,
				"bonus_ammo": _bonus_ammo
			})
	
	if player_node.ammo_manager_node.get_bonus_ammo() > 0:
		rage_meter_node.value = lerp(
			rage_meter_node.value,
			player_node.ammo_manager_node.get_bonus_ammo() / float(player_node.ammo_manager_node.get_max_bonus_ammo()),
			delta * 4)
	else:
		rage_meter_node.value = lerp(rage_meter_node.value, _boost_amount / float(_MAX_BOOST_AMOUNT), delta * 4)


func _synchronize_unreliable(data:Dictionary):
	var previous_ammo = _ammo
	var previous_bonus_ammo = _bonus_ammo
	
	_ammo = data.ammo
	_bonus_ammo = data.bonus_ammo
	
	if _ammo != previous_ammo or _bonus_ammo != previous_bonus_ammo:
		status_bar_node.update_ammo_indicator()


@rpc("any_peer", "call_local")
func play_ammo_pickup_sound() -> void:
	
	if multiplayer.get_remote_sender_id() != 1:
		return
	
	ammo_pickup_audio_player_node.play()

func remove_ammo(amount:int = 1) -> void:
	
	if _bonus_ammo > 0:
		
		_bonus_ammo -= amount
		
		if _bonus_ammo <= 0:
			_boost_amount = 0
			_ammo = max(0, _ammo + _bonus_ammo)
		
	else:
		_ammo = max(0, _ammo - amount)
	
	status_bar_node.update_ammo_indicator()


func add_ammo(amount:int = 1) -> void:
	_ammo = min(_max_ammo, _ammo + amount)
	status_bar_node.update_ammo_indicator()


func get_ammo() -> int:
	return _ammo


func get_max_ammo() -> int:
	return _max_ammo


func get_bonus_ammo() -> int:
	return _bonus_ammo


func get_max_bonus_ammo() -> int:
	return _max_bonus_ammo


@rpc("any_peer", "call_local")
func boost_obtained(over_limit:bool):
	if multiplayer.get_remote_sender_id() != 1:
		return
	
	if over_limit:
		AudioManager.play_sound(EVIL_LAUGH_SOUND)
	else:
		if player_node.is_local():
			AudioManager.play_sound(OVER_LIMIT_LAUGH_SOUND)


func boost():
	_boost_amount += 1
	player_node.wide_spread = true
	
	var over_limit:bool = _boost_amount >= _MAX_BOOST_AMOUNT
	
	if over_limit:
		_ammo = _max_ammo
		_bonus_ammo = 6
		
		player_node.wide_spread = false
		status_bar_node.update_ammo_indicator()
		
	
	boost_obtained.rpc(over_limit)
	
