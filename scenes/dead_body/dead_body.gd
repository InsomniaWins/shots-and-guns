extends Node2D

@onready var splat_audio_player_node:AudioStreamPlayer2D = $Splat


func set_entity_data(data:Dictionary):
	global_position = data.position
	
	var body_color_average:float = (data.color.r + data.color.g + data.color.b) / 3.0
	var outline_color = Color.WHITE if body_color_average <= 0.5 else Color.BLACK
	
	$Body.material = $Body.material.duplicate()
	$Body.scale.y = 1 if randf() > 0.5 else -1
	
	var darken_amount:float = 0.75
	
	$Body.material.set_shader_parameter("tint_color", data.color.darkened(darken_amount))
	$Body.material.set_shader_parameter("color", outline_color.darkened(darken_amount))
	
	$Body/Hat.texture = HatManager.get_hat_texture(data.hat)
	$Body/Hat.modulate = Color.WHITE.darkened(darken_amount)

func _ready():
	splat_audio_player_node.play()
