extends MarginContainer


@export_node_path("LineEdit") var line_edit_node_path:
	set(path):
		line_edit_node_path = path
		
		if is_instance_valid(line_edit_node):
			line_edit_node.focus_entered.disconnect(_on_line_edit_focus_entered)
			line_edit_node.focus_exited.disconnect(_on_line_edit_focus_exited)
		
		if !is_inside_tree():
			await ready
		
		line_edit_node = get_node(line_edit_node_path)
		line_edit_node.focus_entered.connect(_on_line_edit_focus_entered)
		line_edit_node.focus_exited.connect(_on_line_edit_focus_exited)

@onready var line_edit_node:LineEdit
@onready var controller_keyboard_input_node := $ControllerKeyboardInput


func _on_line_edit_focus_entered():
	line_edit_node.caret_column = line_edit_node.text.length()
	visible = true
	activate()

func _on_line_edit_focus_exited():
	deactivate()
	visible = false

func activate():
	controller_keyboard_input_node.activate()

func deactivate():
	controller_keyboard_input_node.deactivate()

func _on_controller_keyboard_input_backspace():
	var new_text:String = line_edit_node.text
	var char_index:int = line_edit_node.caret_column
	
	var length_until_char:int = char_index - 1
	
	if length_until_char < 0:
		return
	
	var length_after_char:int = new_text.length() - length_until_char
	
	new_text = new_text.substr(0, length_until_char)
	new_text = new_text + line_edit_node.text.substr(char_index, length_after_char)
	
	line_edit_node.text = new_text
	line_edit_node.caret_column = max(char_index - 1, 0)


func _on_controller_keyboard_input_bumper_left():
	line_edit_node.caret_column -= 1


func _on_controller_keyboard_input_bumper_right():
	line_edit_node.caret_column += 1


func _on_controller_keyboard_input_enter():
	line_edit_node.text_submitted.emit(line_edit_node.text)


func _on_controller_keyboard_input_letter_selected(letter):
	
	
	var new_text:String = line_edit_node.text
	var caret_column:int = line_edit_node.caret_column + 1
	new_text = new_text.insert(line_edit_node.caret_column, letter)
	
	if line_edit_node.max_length > 0:
		if new_text.length() > line_edit_node.max_length:
			return
	
	line_edit_node.text = new_text
	line_edit_node.caret_column = caret_column


func _on_controller_keyboard_input_space():
	_on_controller_keyboard_input_letter_selected(" ")
