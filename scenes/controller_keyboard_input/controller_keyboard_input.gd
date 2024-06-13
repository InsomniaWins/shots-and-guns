extends Control

signal letter_selected(letter:String)
signal backspace
signal enter
signal space
signal bumper_left
signal bumper_right

@export var active:bool = false

const caps_map:Dictionary = {
	"0":")",
	"9":"(",
	"8":"*",
	"7":"&",
	"6":"^",
	"5":"%",
	"4":"$",
	"3":"#",
	"2":"@",
	"1":"!",
	"-":"_",
	"=":"+",
	"[":"{",
	"]":"}",
	";":":",
	"/":"?",
	"\'":"\"",
	"\\":"|",
	",":"<",
	".":">",
	"`":"~"
}

var selected_button_vector:Vector2 = Vector2(0,0)
var caps_lock:bool = true

@onready var selected_character_outline_node:NinePatchRect = $SelectedCharacterOutline
@onready var character_grid_container_node:GridContainer = $GridContainer

func _unhandled_input(event):
	if active and event.is_pressed() and !event.is_echo():
		
		if event is InputEventJoypadButton:
			if event.button_index == JOY_BUTTON_LEFT_STICK:
				toggle_caps_lock()
				get_viewport().set_input_as_handled()
			if event.button_index == JOY_BUTTON_X:
				backspace.emit()
				get_viewport().set_input_as_handled()
			if event.button_index == JOY_BUTTON_Y:
				space.emit()
				get_viewport().set_input_as_handled()
			if event.button_index == JOY_BUTTON_B:
				enter.emit()
				get_viewport().set_input_as_handled()
			if event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
				bumper_right.emit()
				get_viewport().set_input_as_handled()
			if event.button_index == JOY_BUTTON_LEFT_SHOULDER:
				bumper_left.emit()
				get_viewport().set_input_as_handled()
		
		if event.is_action_pressed("menu_move_down"):
			
			var strength:float = event.get_action_strength("menu_move_down")
			
			if strength == 1.0:
				move_down()
				get_viewport().set_input_as_handled()
		if event.is_action_pressed("menu_move_up"):
			var strength:float = event.get_action_strength("menu_move_up")
			
			if strength == 1.0:
				move_up()
				get_viewport().set_input_as_handled()
		if event.is_action_pressed("menu_move_right"):
			
			var strength:float = event.get_action_strength("menu_move_right")
			
			if strength == 1.0:
				move_right()
				get_viewport().set_input_as_handled()
		if event.is_action_pressed("menu_move_left"):
			var strength:float = event.get_action_strength("menu_move_left")
			
			if strength == 1.0:
				move_left()
				get_viewport().set_input_as_handled()
		if event.is_action_pressed("menu_select"):
			select()
			get_viewport().set_input_as_handled()



func toggle_caps_lock() -> void:
	caps_lock = !caps_lock
	update_letter_caps()


func update_letter_caps() -> void:
	
	for character_control_node:Control in character_grid_container_node.get_children():
		var rich_label_node:RichTextLabel = character_control_node.get_child(0)
		
		var caps_keys = caps_map.keys()
		var caps_values = caps_map.values()
		
		if caps_lock:
			if rich_label_node.text != "_":
				rich_label_node.text = rich_label_node.text.capitalize()
			
			if caps_values.has(rich_label_node.text):
				var caps_index:int = caps_values.find(rich_label_node.text)
				var key = caps_keys[caps_index]
				rich_label_node.text = key
			
		else:
			rich_label_node.text = rich_label_node.text.to_lower()
			
			if caps_keys.has(rich_label_node.text):
				rich_label_node.text = caps_map[rich_label_node.text]
		
	



func move_down():
	move(Vector2.DOWN)


func move_up():
	move(Vector2.UP)


func move_right():
	move(Vector2.RIGHT)


func move_left():
	move(Vector2.LEFT)


func move(direction:Vector2) -> void:
	
	direction.x = sign(direction.x)
	direction.y = sign(direction.y)
	
	selected_button_vector.x += direction.x
	
	if direction.x < 0:
		
		if selected_button_vector.x < 0:
			selected_button_vector.x = 9
		
		while !is_instance_valid(get_selected_character_node()):
			selected_button_vector.x -= 1
		
	elif direction.x > 0:
		
		if selected_button_vector.x > 9:
			selected_button_vector.x = 0
		
		while !is_instance_valid(get_selected_character_node()):
			selected_button_vector.x += 1
			
			if selected_button_vector.x > 9:
				selected_button_vector.x = 0
	
	
	
	selected_button_vector.y += direction.y
	
	if direction.y > 0:
		
		if selected_button_vector.y > 4:
			selected_button_vector.y = 0
		
		while !is_instance_valid(get_selected_character_node()):
			selected_button_vector.y += 1
			
			if selected_button_vector.y > 4:
				selected_button_vector.y = 0
		
	elif direction.y < 0:
		
		if selected_button_vector.y < 0:
			selected_button_vector.y = 4
		
		while !is_instance_valid(get_selected_character_node()):
			selected_button_vector.y -= 1
			
			if selected_button_vector.y < 0:
				selected_button_vector.y = 4
	
	update_selected_character_outline()


func get_child_index_from_button_vector(button_vector:Vector2) -> int:
	
	var button_index:int = int(button_vector.x)
	
	while button_vector.y > 0:
		button_vector.y -= 1
		button_index += 10
	
	return button_index


func get_selected_character_node() -> Control:
	
	var child_index:int = get_child_index_from_button_vector(selected_button_vector)
	
	if child_index == -1:
		return null
	
	if character_grid_container_node.get_child_count() < child_index + 1:
		return null
	
	return character_grid_container_node.get_child(child_index)


func update_selected_character_outline() -> void:
	selected_character_outline_node.global_position = get_selected_character_node().global_position + Vector2(-3, -3)



func select():

	letter_selected.emit(get_selected_character_node().get_child(0).text)



func activate():
	for button_menu_node in get_tree().get_nodes_in_group("button_menu"):
		button_menu_node.deactivate()
	
	active = true
	update_selected_character_outline()


func deactivate():
	active = false
