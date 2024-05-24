extends Node2D

var move_speed:float = 300
var shooter:int = -1

@onready var shape_cast_node:ShapeCast2D = $ShapeCast2D

func set_entity_data(data:Dictionary):
	position = data.position
	rotation = data.rotation
	shooter = data.shooter

func _process(_delta):
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
	
	_move_and_collide(next_position_local)



func _move_and_collide(next_position_local:Vector2):
	
	var should_free:bool = false
	
	position += next_position_local
	
	if shape_cast_node.is_colliding():
		
		for i in shape_cast_node.get_collision_count():
			var collider = shape_cast_node.get_collider(i)
			
			if collider.is_in_group("hitbox"):
				
				if collider.get_parent().is_in_group("player"):
					
					var entity = collider.get_node_or_null(collider.entity_node_path)
					
					should_free = true
					var should_damage = true
					
					if is_instance_valid(entity):
						if entity.is_in_group("player"):
							if entity.peer_id == shooter:
								should_free = false
								should_damage = false
					
					if should_damage:
						collider.on_damage(1)
					
				else:
					should_free = false
			elif collider.is_in_group("bullet"):
				should_free = false
			else:
				should_free = true
			
		
		if should_free:
			Network.free_entity.rpc(get_path())



