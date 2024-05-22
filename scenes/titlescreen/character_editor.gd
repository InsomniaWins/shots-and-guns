extends ColorRect

@onready var username_label_node:Label = $UsernameLabel
@onready var username_edit_node:LineEdit = $UsernameEdit
@onready var edit_character_menu_node = $EditCharacterMenu
@onready var hat_label_node:Label = $HatLabel
@onready var hat_edit_menu_node = $HatEditMenu

func _ready():
	username_edit_node.text = Network.my_information.username


func _on_username_edit_text_submitted(new_text):
	username_edit_node.release_focus()


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
