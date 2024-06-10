extends ColorRect

@onready var username_label_node:Label = $UsernameLabel
@onready var username_edit_node:LineEdit = $UsernameEdit
@onready var edit_character_menu_node = $EditCharacterMenu
@onready var hat_label_node:Label = $HatLabel
@onready var hat_edit_menu_node = $HatEditMenu
@onready var controller_keyboard_input_node := $ControllerKeyboardInput

func _ready():
	username_edit_node.text = Network.my_information.username


func _on_username_edit_text_submitted(_new_text):
	username_edit_node.release_focus()
	controller_keyboard_input_node.deactivate()
	controller_keyboard_input_node.visible = false
	$"..".update_username()


func _on_username_edit_focus_exited():
	Network.my_information.username = username_edit_node.text
	edit_character_menu_node.activate()


func update_hat_display():
	hat_label_node.text = "HAT: " + HatManager.get_hat_name(Network.my_information.hat)
	get_parent().update_hat_texture()

func _on_hat_edit_menu_menu_selected():
	var button_name = hat_edit_menu_node.button_names[hat_edit_menu_node.selected_button_index]
	
	match button_name:
		"PREVIOUS HAT":
			Network.my_information.hat = HatManager.decrement_hat(Network.my_information.hat)
		"NEXT HAT":
			Network.my_information.hat = HatManager.increment_hat(Network.my_information.hat)
		"REMOVE HAT":
			Network.my_information.hat = HatManager.Hats.NONE
		"BACK":
			hat_edit_menu_node.deactivate()
			hat_edit_menu_node.visible = false
			edit_character_menu_node.activate()
	
	update_hat_display()


func _on_username_edit_focus_entered():
	
	username_edit_node.caret_column = username_edit_node.text.length()
	
	controller_keyboard_input_node.visible = true
	controller_keyboard_input_node.activate()





func _on_controller_keyboard_input_backspace():
	var new_text:String = username_edit_node.text
	var char_index:int = username_edit_node.caret_column
	
	var length_until_char:int = char_index - 1
	
	if length_until_char < 0:
		return
	
	var length_after_char:int = new_text.length() - length_until_char
	
	new_text = new_text.substr(0, length_until_char)
	new_text = new_text + username_edit_node.text.substr(char_index, length_after_char)
	
	username_edit_node.text = new_text
	username_edit_node.caret_column = max(char_index - 1, 0)


func _on_controller_keyboard_input_bumper_left():
	username_edit_node.caret_column -= 1


func _on_controller_keyboard_input_bumper_right():
	username_edit_node.caret_column += 1


func _on_controller_keyboard_input_enter():
	_on_username_edit_text_submitted(username_edit_node.text)


func _on_controller_keyboard_input_letter_selected(letter):
	
	
	var new_text:String = username_edit_node.text
	var caret_column:int = username_edit_node.caret_column + 1
	new_text = new_text.insert(username_edit_node.caret_column, letter)
	
	if username_edit_node.max_length > 0:
		if new_text.length() > username_edit_node.max_length:
			return
	
	username_edit_node.text = new_text
	username_edit_node.caret_column = caret_column


func _on_controller_keyboard_input_space():
	_on_controller_keyboard_input_letter_selected(" ")

