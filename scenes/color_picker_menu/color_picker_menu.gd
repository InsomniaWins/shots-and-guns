extends Control

signal menu_moved
signal menu_selected


@export var active:bool = false

var selected_button_vector:Vector2 = Vector2(0,0)

@onready var grid_container_node:GridContainer = $GridContainer
@onready var selected_color_outline_node:NinePatchRect = $SelectedColor
@onready var move_audio_player_node:AudioStreamPlayer = $MoveSound

func _unhandled_input(event):
	if active:
		if event.is_action_pressed("aim_down") and !event.is_echo():
			move_down()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("aim_up") and !event.is_echo():
			move_up()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("aim_right") and !event.is_echo():
			move_right()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("aim_left") and !event.is_echo():
			move_left()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("select") and !event.is_echo():
			select()
			get_viewport().set_input_as_handled()


func move_right():
	move(Vector2.RIGHT)

func move_left():
	move(Vector2.LEFT)

func move_down():
	move(Vector2.DOWN)

func move_up():
	move(Vector2.UP)

func move(move_direction:Vector2):
	var h_direction = sign(move_direction.x)
	var v_direction = sign(move_direction.y)
	
	if h_direction == 0.0 and v_direction == 0.0:
		return
	
	move_audio_player_node.play()
	
	if h_direction != 0.0:
		selected_button_vector.x += h_direction
		if selected_button_vector.x > 5:
			selected_button_vector.x = 0
		elif selected_button_vector.x < 0:
			selected_button_vector.x = 5
	
	if v_direction != 0.0:
		selected_button_vector.y += v_direction
		if selected_button_vector.y > 4:
			selected_button_vector.y = 0
		elif selected_button_vector.y < 0:
			selected_button_vector.y = 4
	
	menu_moved.emit()
	update_selection_graphic()


func get_selected_color_node() -> Control:
	return get_color_node(selected_button_vector)

func get_color_node(button_vector:Vector2) -> Control:
	
	var button_index:int = int(button_vector.x)
	for i in button_vector.y:
		button_index += 6
	
	var color_node:Control = grid_container_node.get_child(button_index)
	
	return color_node

func update_selection_graphic():
	
	var selected_node_index:int = int(selected_button_vector.x)
	for i in selected_button_vector.y:
		selected_node_index += 6
	
	var selected_color_node:Control = grid_container_node.get_child(selected_node_index)
	selected_color_outline_node.global_position.x = selected_color_node.global_position.x - 2
	selected_color_outline_node.global_position.y = selected_color_node.global_position.y - 2
	


func select():
	AudioManager.play_sound(preload("res://sounds/button_select.wav"), -5)
	menu_selected.emit()

func activate():
	for button_menu_node in get_tree().get_nodes_in_group("button_menu"):
		button_menu_node.deactivate()
	
	active = true


func deactivate():
	active = false
