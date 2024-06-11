extends Control

signal menu_moved
signal menu_selected

const MENU_MOVE_SOUND:AudioStream = preload("res://sounds/button_move.ogg")

@export var button_names:Array[String]
@export var active:bool = false:
	set(value):
		active = value
		update_active_effect()

var selected_button_index:int = 0
var play_sound_timer:float = 0.0

@onready var labels_vbox_node = $VBoxContainer
@onready var selection_label_node = $SelectionLabel
@onready var background_node = $Background

func _ready():
	update_active_effect()
	update_labels()
	update_selected_button_graphic()


func _unhandled_input(event):
	
	if !Settings.accept_input:
		return
	
	if active and event.is_pressed() and !event.is_echo():
		if event.is_action_pressed("menu_move_down"):
			move_down()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("menu_move_up"):
			move_up()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("select"):
			select()
			get_viewport().set_input_as_handled()

func _process(delta):
	play_sound_timer = max(0.0, play_sound_timer - delta)


func update_active_effect():
	
	
	if !is_node_ready():
		await ready
	
	if active:
		labels_vbox_node.modulate.a = 1
	else:
		labels_vbox_node.modulate.a = 0.3


func add_button(button_name:String):
	button_names.append(button_name)
	update_labels()


func clear_buttons():
	button_names.clear()
	update_labels()

func button_gui_input(event:InputEvent, button_index:int) -> void:
	
	if !active:
		return
	
	if event is InputEventMouseButton:
		if event.pressed and !event.is_echo():
			if event.button_index == MOUSE_BUTTON_LEFT:
				
				if button_index == selected_button_index:
					select()
	

func update_labels() -> void:
	 
	var current_button_index = labels_vbox_node.get_child_count()
	while labels_vbox_node.get_child_count() < get_button_count():
		var new_label_node = Label.new()
		new_label_node.add_theme_font_override("font", preload("res://fonts/normal/normal.png"))
		new_label_node.mouse_filter = Control.MOUSE_FILTER_STOP
		#new_label_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label_node.mouse_entered.connect(move_to_button.bind(current_button_index))
		new_label_node.gui_input.connect(button_gui_input.bind(current_button_index))
		labels_vbox_node.add_child(new_label_node)
		
		current_button_index += 1
	
	while labels_vbox_node.get_child_count() > get_button_count():
		labels_vbox_node.get_child(0).queue_free()
	
	for i in button_names.size():
		var label_node = get_button_label(i)
		label_node.text = button_names[i]
	
	update_selected_button_graphic()

func select():
	AudioManager.play_sound(preload("res://sounds/button_select.ogg"), 0.0, randf() * 0.25 + 0.75)
	menu_selected.emit()


func move_to_button(button_index:int, play_sound:bool = true) -> void:
	
	if !active:
		return
	
	while button_index < 0:
		button_index += button_names.size()
	
	while button_index > button_names.size() - 1:
		button_index -= button_names.size()
	
	var direction:int = selected_button_index - button_index
	while button_index != selected_button_index:
		move(direction, false)
	
	if play_sound and play_sound_timer <= 0.0:
		AudioManager.play_sound(MENU_MOVE_SOUND, 0.0, randf() * 0.25 + 0.75)
		play_sound_timer = 0.05



func move(direction:int, play_sound:bool = true) -> void:
	direction = sign(direction)
	
	if direction == 0:
		return
	
	if play_sound and play_sound_timer <= 0.0:
		AudioManager.play_sound(MENU_MOVE_SOUND, 0.0, randf() * 0.25 + 0.75)
		play_sound_timer = 0.05
	
	selected_button_index += direction
	
	if selected_button_index > get_button_count() - 1:
		selected_button_index = 0
	
	if selected_button_index < 0:
		selected_button_index = get_button_count() - 1
	
	update_selected_button_graphic()
	menu_moved.emit()


func update_selected_button_graphic() -> void:
	selection_label_node.visible = get_button_count() > 0
	
	if selection_label_node.visible:
		
		selection_label_node.position.y = get_selected_button_label().position.y
	
	for label_node in labels_vbox_node.get_children():
		label_node.self_modulate = Color("567B79")
	
	var selected_button_label:Label = get_selected_button_label()
	if is_instance_valid(selected_button_label):
		selected_button_label.self_modulate = Color("C2D368")


func get_button_count() -> int:
	return button_names.size()


func move_down():
	move(1)


func move_up():
	move(-1)


func get_selected_button_label() -> Label:
	return get_button_label(selected_button_index)


func get_button_label(index:int) -> Label:
	
	if labels_vbox_node.get_child_count() < index + 1:
		return null
	
	if index < 0:
		return null
	
	return labels_vbox_node.get_child(index)


func activate():
	for button_menu_node in get_tree().get_nodes_in_group("button_menu"):
		button_menu_node.deactivate()
	
	active = true
	update_active_effect()
	update_selected_button_graphic()


func deactivate():
	active = false
	update_active_effect()
	



func _on_v_box_container_resized():
	background_node.size = labels_vbox_node.size
