extends Control


const PLAYER_ICON_TEXTURE := preload("res://textures/gui/minimap/player_icon.png")

@onready var player_icons_parent_node := $PlayerIcons
@onready var my_player_node := $"../.."

func _process(_delta):
	
	update_player_icons()
	


func update_player_icons():
	var player_nodes:Array = get_tree().get_nodes_in_group("player")
	
	while player_nodes.size() > _get_player_icon_count():
		_add_player_icon()
	
	while player_nodes.size() < _get_player_icon_count():
		_remove_player_icon()
	
	for i in player_nodes.size():
		var player_node = player_nodes[i]
		var player_icon:TextureRect = player_icons_parent_node.get_child(i)
		
		if player_node != my_player_node:
			player_icon.modulate = Color("B45252")
		else:
			player_icon.modulate = Color.WHITE
		
		player_icon.visible = !player_node.is_respawning()
		
		player_icon.position = Vector2(-3,-3) + global_position_to_minimap_position(player_node.global_position)
		
		#player_icon.position = player_icon.position.clamp(
			#minimap_scale * (get_viewport().get_camera_2d().position - viewport_size),
			#minimap_scale * (get_viewport().get_camera_2d().position + viewport_size)
		#)


func global_position_to_minimap_position(input_position:Vector2, clamped:bool = false) -> Vector2:
	
	var viewport_size:Vector2 = Vector2(512, 320)
	
	var minimap_scale:Vector2 = Vector2(
		
		float(size.x) / viewport_size.x,
		float(size.y) / viewport_size.y
		
	)
	
	var minimap_center_position:Vector2 = size * 0.5
	
	var my_position = my_player_node.global_position
	
	var position_on_minimap:Vector2 = input_position - my_position
	position_on_minimap = position_on_minimap.clamp(-viewport_size * 0.5, viewport_size * 0.5)
	
	var minimap_position = minimap_center_position + position_on_minimap * minimap_scale
	
	return minimap_position


func _add_player_icon():
	var new_icon_node:TextureRect = TextureRect.new()
	new_icon_node.texture = PLAYER_ICON_TEXTURE
	new_icon_node.pivot_offset = Vector2(3,3)
	new_icon_node.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	new_icon_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	player_icons_parent_node.add_child(new_icon_node)


func _remove_player_icon():
	
	if _get_player_icon_count() <= 0:
		return
	
	player_icons_parent_node.remove_child(player_icons_parent_node.get_child(0))


func _get_player_icon_count() -> int:
	return player_icons_parent_node.get_child_count()
