extends Timer

const FootstepParticle := preload("res://scenes/footstep_particle/footstep_particle.tscn")
const FOOTSTEP_SOUND:AudioStream = preload("res://sounds/footstep.ogg")

@onready var player_node := $".."

var foot_index:int = 0

func _process(_delta):
	wait_time = 20.0 / player_node.move_speed
	
	if is_stopped():
		if player_node.moving:
			_on_timeout()
			start()
	else:
		if !player_node.moving:
			stop()


func _on_timeout():
	var audio_player_node:AudioStreamPlayer2D = AudioManager.play_sound_2d(FOOTSTEP_SOUND, player_node.global_position, 0.0, 0.75 + randf() * 0.25)
	audio_player_node.attenuation = 20
	
	var particle = FootstepParticle.instantiate()
	player_node.get_parent().add_child(particle)
	particle.position = player_node.position + Vector2(
		-3 if foot_index == 0 else 3,
		7)
	
	foot_index = (foot_index + 1) % 2
