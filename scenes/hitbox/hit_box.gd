extends Area2D
class_name HitBox

signal damaged(amount:int)


@export_node_path var entity_node_path

func on_damage(amount:int) -> void:
	damaged.emit(amount)
