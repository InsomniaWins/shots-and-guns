extends Control


@onready var margin_container_node:MarginContainer = $MarginContainer
@onready var player_list_node:VBoxContainer = margin_container_node.get_node("PlayerList")
@onready var outline_node:NinePatchRect = $Outline
@onready var players_node = $Players
@onready var player_spawn_point_node = $PlayerSpawnPoint
@onready var start_button_node = $StartButton


func _ready():
	Network.player_list_updated.connect(_players_dictionary_updated)
	
	for player_id in Network.players:
		spawn_player(player_id)
	
	Network.player_joined.connect(server_on_player_joined)
	Network.player_left.connect(server_on_player_left)
	
	if multiplayer.is_server():
		start_button_node.visible = true
		Network.allow_new_connections()
	else:
		start_button_node.visible = false

func server_on_player_joined(peer_id):
	spawn_player(peer_id)

func server_on_player_left(peer_id):
	despawn_player(peer_id)


func despawn_player(peer_id:int) -> void:
	var player_node_name:String = str("player_", peer_id)
	if !players_node.has_node(player_node_name):
		return
	
	var player_node = players_node.get_node(player_node_name)
	player_node.queue_free()


func spawn_player(peer_id:int) -> void:
	var player_node = Network.spawn_player(peer_id, players_node, player_spawn_point_node.position, peer_id == multiplayer.get_unique_id())


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
	





