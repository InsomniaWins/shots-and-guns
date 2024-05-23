extends Node2D

var move_speed:float = 300
var shooter:int = -1

@onready var shape_cast_node:ShapeCast2D = $ShapeCast2D

func set_entity_data(data:Dictionary):
	position = data.position
	rotation = data.rotation
	shooter = data.shooter

func _process(delta):
	if multiplayer.is_server():
		Network.synchronize_node_unreliable.rpc(get_path(), {
			"position": position,
			"rotation": rotation
		})


func _synchronize_unreliable(data:Dictionary):
	position = data.position
	rotation = data.rotation


func _physics_process(delta):
	
	if !multiplayer.is_server():
		return
	
	var distance = move_speed * delta
	var next_position_local = Vector2.RIGHT.rotated(rotation) * distance
	
	shape_cast_node.target_position = next_position_local
	shape_cast_node.force_shapecast_update()
	
	var should_free:bool = false
	
	position += next_position_local
	
	if shape_cast_node.is_colliding():
		
		for i in shape_cast_node.get_collision_count():
			var collider = shape_cast_node.get_collider(i)
			
			if collider.is_in_group("player"):
				var player_node = collider
				
				if player_node.peer_id != shooter:
					player_node.health_manager_node.take_damage()
					should_free = true
				
			else:
				should_free = true
			
		
		if should_free:
			Network.free_entity.rpc(get_path())



