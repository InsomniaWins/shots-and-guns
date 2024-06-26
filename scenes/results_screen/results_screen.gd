extends Control


@onready var character_scaler_node:Control = $CharacterScaler
@onready var winner_character_body_node:Sprite2D = $CharacterScaler/WinnerCharacter/Body
@onready var winner_character_hat_node:Sprite2D = $CharacterScaler/WinnerCharacter/Body/Hat
@onready var winner_username_label_node:Label = $CharacterScaler/UsernameLabel
@onready var win_audio_player_node:AudioStreamPlayer = $WinSound
@onready var lose_audio_player_node:AudioStreamPlayer = $LoseSound
@onready var lobby_button_menu_node := $LobbyButtonMenu

func _ready():
	if Network.is_online() and multiplayer.is_server():
		lobby_button_menu_node.visible = true
		lobby_button_menu_node.activate()
		$WaitingOnHostLabel.visible = false


# called when all peers are ready
@rpc("authority", "call_local")
func _rpc_network_ready():
	_network_ready()


func _network_ready():
	
	if Network.is_online() and multiplayer.is_server():
		
		var winner_id = MatchResults.winner
		var winner_name = Network.players[MatchResults.winner].username
		var winner_color = Network.players[MatchResults.winner].color
		var winner_hat = Network.players[MatchResults.winner].hat
		
		show_winner.rpc(winner_id, winner_name, winner_color, winner_hat)
	


@rpc("authority", "call_local")
func show_winner(winner_id:int, winner_name:String, winner_color:Color, winner_hat:int) -> void:
	
	if winner_id == multiplayer.get_unique_id():
		win_audio_player_node.play()
	else:
		lose_audio_player_node.play()
	
	character_scaler_node.visible = true
	
	winner_username_label_node.text = winner_name
	winner_character_hat_node.texture = HatManager.get_hat_texture(winner_hat)
	
	winner_character_body_node.material.set_shader_parameter("tint_color", winner_color)
	
	var body_color_average:float = (winner_color.r + winner_color.g + winner_color.b) / 3.0
	var outline_color = Color.WHITE if body_color_average <= 0.5 else Color.BLACK
	
	winner_character_body_node.material.set_shader_parameter("color", outline_color)



func _on_lobby_button_menu_menu_selected():
	var button_name = lobby_button_menu_node.button_names[lobby_button_menu_node.selected_button_index]
	
	match button_name:
		"RETURN TO LOBBY":
			SceneManager.change_scene.rpc("res://scenes/lobby/lobby.tscn")
	
