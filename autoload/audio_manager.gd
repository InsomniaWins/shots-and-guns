extends Node



func play_sound(audio, volume_db:float = 0.0) -> AudioStreamPlayer:
	if audio is String:
		audio = load(audio)
	
	if !(audio is AudioStream):
		return
	
	var player_node:AudioStreamPlayer = AudioStreamPlayer.new()
	player_node.stream = audio
	player_node.volume_db = volume_db
	add_child(player_node)
	player_node.finished.connect(player_node.queue_free)
	player_node.play()
	
	return player_node
