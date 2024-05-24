extends CanvasLayer

@onready var flash_rect_node = $FlashRect

func flash():
	flash_rect_node.color.a = 0.25

func _process(delta):
	flash_rect_node.color.a = max(0.0, flash_rect_node.color.a - delta * 10)
