extends Area2D

signal damaged(amount:int)


@export_node_path("Node2D") var entity_node_path

func on_damage(amount:int) -> void:
	damaged.emit(amount)
