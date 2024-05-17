extends Control


@onready var message_panel_node = $MessagePanel


func _on_host_button_pressed():
	SceneManager.change_scene("res://scenes/host_screen/host_screen.tscn")


func _on_join_button_pressed():
	SceneManager.change_scene("res://scenes/join_screen/join_screen.tscn")


func show_message(message:String) -> void:
	message_panel_node.get_node("Label").text = message
	message_panel_node.visible = true


func _on_close_message_panel_button_pressed():
	message_panel_node.visible = false


