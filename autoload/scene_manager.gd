extends Node

signal changed_scene(current_scene)


# private func of change_scene used to defer func call
func _change_scene(next_scene_path:String, post_function:Callable) -> void:
	var next_scene:Node = load(next_scene_path).instantiate()
	var current_scene = get_current_scene()
	var current_scene_parent = get_current_scene_parent()
	var freed_scenes_parent = get_freed_scenes_parent()
	
	
	current_scene_parent.remove_child(current_scene)
	freed_scenes_parent.add_child(current_scene)
	current_scene.queue_free()
	
	current_scene_parent.add_child(next_scene)
	
	if !next_scene.is_node_ready():
		await next_scene.ready
	
	if !post_function.is_null():
		post_function.call()
	
	changed_scene.emit(next_scene)


func change_scene(next_scene_path:String, post_function:Callable = Callable()) -> void:
	_change_scene.call_deferred(next_scene_path, post_function)


func get_freed_scenes_parent() -> Node:
	return get_tree().current_scene.get_node("%FreedScenesParent")


func get_freed_scenes() -> Array[Node]:
	return get_freed_scenes_parent().get_children()


func get_current_scene_parent() -> Control:
	return get_tree().current_scene.get_node("%CurrentSceneParent")


func get_current_scene() -> Node:
	return get_current_scene_parent().get_child(0)
	


