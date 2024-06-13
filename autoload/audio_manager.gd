extends Node

func play_sound_2d(audio, position, volume_db:float = 0.0, pitch:float = 1.0) -> AudioStreamPlayer2D:
	
	if audio is String:
		audio = load(audio)
	
	if !(audio is AudioStream):
		return
	
	var player_node:AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	player_node.stream = audio
	player_node.volume_db = volume_db
	player_node.pitch_scale = pitch
	player_node.position = position
	add_child(player_node)
	player_node.finished.connect(player_node.queue_free)
	player_node.play()
	
	return player_node

func play_sound(audio, volume_db:float = 0.0, pitch:float = 1) -> AudioStreamPlayer:
	if audio is String:
		audio = load(audio)
	
	if !(audio is AudioStream):
		return
	
	var player_node:AudioStreamPlayer = AudioStreamPlayer.new()
	player_node.stream = audio
	player_node.volume_db = volume_db
	player_node.pitch_scale = pitch
	add_child(player_node)
	player_node.finished.connect(player_node.queue_free)
	player_node.play()
	
	return player_node
