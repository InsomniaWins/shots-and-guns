extends Control


@onready var message_panel_node:Control = $MessagePanel
@onready var username_edit_node:LineEdit = $HBoxContainer/CharacterEditor/UsernameEdit
@onready var hat_sprite_node:Sprite2D = $Character/Body/Hat
@onready var hat_name_label_node:Label = $HBoxContainer/CharacterEditor/HatNameLabel
@onready var player_color_picker_node:ColorPicker = $PlayerColorEditor/ScrollContainer/PlayerColorPicker
@onready var player_color_picker_parent:ColorRect = $PlayerColorEditor
@onready var body_sprite_node:Sprite2D = $Character/Body

@onready var main_menu_node = $MainMenu
@onready var character_editor_node = $CharacterEditor
@onready var edit_character_menu_node = $CharacterEditor/EditCharacterMenu
@onready var body_color_picker_node = $BodyColorPicker

func _ready():
	username_edit_node.text = Network.my_information.username
	hat_sprite_node = $Character/Body/Hat
	hat_name_label_node = $HBoxContainer/CharacterEditor/HatNameLabel
	
	update_body_color()
	update_username()
	add_swatches_to_color_picker(player_color_picker_node)
	


func add_swatches_to_color_picker(color_picker:ColorPicker) -> void:
	color_picker.add_preset(Color("F2F0E5"))
	color_picker.add_preset(Color("B8B5B9"))
	color_picker.add_preset(Color("868188"))
	color_picker.add_preset(Color("646365"))
	color_picker.add_preset(Color("45444F"))
	color_picker.add_preset(Color("3A3858"))
	color_picker.add_preset(Color("212123"))
	color_picker.add_preset(Color("352B42"))
	color_picker.add_preset(Color("43436A"))
	color_picker.add_preset(Color("4B80CA"))
	color_picker.add_preset(Color("68C2D3"))
	color_picker.add_preset(Color("A2DCC7"))
	color_picker.add_preset(Color("EDE19E"))
	color_picker.add_preset(Color("D3A068"))
	color_picker.add_preset(Color("B45252"))
	color_picker.add_preset(Color("6A536E"))
	color_picker.add_preset(Color("4B4158"))
	color_picker.add_preset(Color("80493A"))
	color_picker.add_preset(Color("A77B5B"))
	color_picker.add_preset(Color("E5CEB4"))
	color_picker.add_preset(Color("C2D368"))
	color_picker.add_preset(Color("8AB060"))
	color_picker.add_preset(Color("567B79"))
	color_picker.add_preset(Color("4E584A"))
	color_picker.add_preset(Color("7B7243"))
	color_picker.add_preset(Color("B2B47E"))
	color_picker.add_preset(Color("EDC8C4"))
	color_picker.add_preset(Color("CF8ACB"))
	color_picker.add_preset(Color("5F556A"))


func update_hat_texture() -> void:
	$Character/Body/Hat.texture = HatManager.get_hat_texture(Network.my_information.hat)
	$HBoxContainer/CharacterEditor/HatNameLabel.text = "Hat: " + HatManager.get_hat_name(Network.my_information.hat)

func _on_host_button_pressed():
	SceneManager.change_scene("res://scenes/host_screen/host_screen.tscn")


func _on_join_button_pressed():
	SceneManager.change_scene("res://scenes/join_screen/join_screen.tscn")


func show_message(message:String) -> void:
	message_panel_node.get_node("Label").text = message
	message_panel_node.visible = true
	main_menu_node.deactivate()
	$MessagePanel/MesagePanelButtonMenu.activate()

func _on_close_message_panel_button_pressed():
	hide_message()

func hide_message() -> void:
	message_panel_node.visible = false
	main_menu_node.activate()




func _on_increment_hat_pressed():
	Network.my_information.hat = HatManager.increment_hat(Network.my_information.hat)
	update_hat_texture()


func _on_decrement_hat_pressed():
	Network.my_information.hat = HatManager.decrement_hat(Network.my_information.hat)
	update_hat_texture()


func _on_remove_hat_pressed():
	Network.my_information.hat = HatManager.Hats.NONE
	update_hat_texture()


func _on_player_color_picker_color_changed(color):
	Network.my_information.color = color
	update_hat_texture()


func _on_color_picker_okay_button_pressed():
	player_color_picker_parent.visible = false
	character_editor_node.edit_character_menu_node.activate()


func _on_edit_player_color_button_pressed():
	player_color_picker_parent.visible = true


func _on_username_edit_text_changed(new_text):
	Network.my_information.username = new_text
	update_username()


func update_username():
	$Character/UsernameLabel.text = Network.my_information.username

func _on_main_menu_menu_selected():
	
	var button_name = main_menu_node.button_names[main_menu_node.selected_button_index]
	match button_name:
		
		"HOST GAME":
			SceneManager.change_scene("res://scenes/host_screen/host_screen.tscn")
		
		"JOIN GAME":
			SceneManager.change_scene("res://scenes/join_screen/join_screen.tscn")
		
		"EDIT CHARACTER":
			character_editor_node.visible = true
			main_menu_node.deactivate()
			main_menu_node.visible = false
			edit_character_menu_node.activate()
		
		"SETTINGS":
			SceneManager.change_scene("res://scenes/settings_screen/settings_screen.tscn")
		
		"QUIT":
			get_tree().quit()
	


func _on_edit_character_menu_menu_selected():
	var button_name = edit_character_menu_node.button_names[edit_character_menu_node.selected_button_index]
	match button_name:
		"BACK":
			edit_character_menu_node.deactivate()
			main_menu_node.activate()
			main_menu_node.visible = true
			character_editor_node.visible = false
			Settings.save_settings()
		"USERNAME":
			edit_character_menu_node.deactivate()
			$CharacterEditor/UsernameEdit.grab_focus()
			
		"HAT":
			character_editor_node.hat_edit_menu_node.visible = true
			edit_character_menu_node.deactivate()
			character_editor_node.hat_edit_menu_node.activate()
		"BODY COLOR":
			body_color_picker_node.visible = true
			body_color_picker_node.activate()
			edit_character_menu_node.deactivate()


func _on_body_color_picker_menu_moved():
	
	var body_color:Color = Network.my_information.color
	
	var color_button = body_color_picker_node.get_selected_color_node()
	if color_button is ColorRect:
		body_color = color_button.color
	
	Network.my_information.color = body_color
	
	update_body_color()

func update_body_color():
	
	body_sprite_node.material.set_shader_parameter("tint_color", Network.my_information.color)
	
	var body_color_average:float = (Network.my_information.color.r + Network.my_information.color.g + Network.my_information.color.b) / 3.0
	var outline_color = Color.WHITE if body_color_average <= 0.5 else Color.BLACK
	body_sprite_node.material.set_shader_parameter("color", outline_color)


func _on_body_color_picker_menu_selected():
	body_color_picker_node.visible = false
	body_color_picker_node.deactivate()
	edit_character_menu_node.activate()




func _on_mesage_panel_button_menu_menu_selected():
	var button_name = $MessagePanel/MesagePanelButtonMenu.button_names[$MessagePanel/MesagePanelButtonMenu.selected_button_index]
	
	match button_name:
		"CLOSE MESSAGE":
			hide_message()

