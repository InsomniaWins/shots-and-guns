extends Control

signal menu_moved
signal menu_selected

const MENU_MOVE_SOUND:AudioStream = preload("res://sounds/button_move.ogg")

@export var active:bool = false

var selected_button_vector:Vector2 = Vector2(0,0)

@onready var grid_container_node:GridContainer = $GridContainer
@onready var selected_color_outline_node:NinePatchRect = $SelectedColor

func _ready():
	var x:int = 0
	var y:int = 0
	for color_node in grid_container_node.get_children():
		
		color_node.mouse_entered.connect(move_to_button.bind(Vector2(x, y)))
		color_node.gui_input.connect(button_gui_input.bind(Vector2(x, y)))
		
		x += 1
		if x >= grid_container_node.columns:
			x = 0
			y += 1


func button_gui_input(event:InputEvent, button_vector:Vector2) -> void:
	
	if !active:
		return
	
	if event is InputEventMouseButton:
		if event.pressed and !event.is_echo():
			if event.button_index == MOUSE_BUTTON_LEFT:
				move_to_button(button_vector, false)
				select()
	


func move_to_button(button_vector:Vector2, play_sound:bool = true) -> void:
	
	if !active:
		return
	
	var direction:Vector2 = Vector2(
		int(button_vector.x - selected_button_vector.x),
		int(button_vector.y - selected_button_vector.y)
		)
	
	while button_vector.x != selected_button_vector.x:
		move(Vector2(direction.x, 0), false)
	
	while button_vector.y != selected_button_vector.y:
		move(Vector2(0, direction.y), false)
	
	if play_sound:
		AudioManager.play_sound(MENU_MOVE_SOUND)


func _unhandled_input(event):
	
	if !Settings.accept_input:
		return
	
	if active and !event.is_echo() and event.is_pressed():
		if event.is_action_pressed("menu_move_down"):
			move_down()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("menu_move_up"):
			move_up()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("menu_move_right"):
			move_right()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("menu_move_left"):
			move_left()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("select"):
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

func move(move_direction:Vector2, play_sound:bool = true):
	var h_direction = sign(move_direction.x)
	var v_direction = sign(move_direction.y)
	
	if h_direction == 0.0 and v_direction == 0.0:
		return
	
	if play_sound:
		AudioManager.play_sound(MENU_MOVE_SOUND)
	
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
	AudioManager.play_sound(preload("res://sounds/button_select.ogg"))
	menu_selected.emit()

func activate():
	for button_menu_node in get_tree().get_nodes_in_group("button_menu"):
		button_menu_node.deactivate()
	
	active = true


func deactivate():
	active = false
