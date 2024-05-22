extends Control

signal menu_moved
signal menu_selected


@export var button_names:Array[String]
@export var active:bool = false:
	set(value):
		active = value
		update_active_effect()


var selected_button_index:int = 0


@onready var labels_vbox_node = $VBoxContainer
@onready var selection_label_node = $SelectionLabel


func _ready():
	update_active_effect()
	update_labels()
	update_selected_button_graphic()


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


func update_labels() -> void:
	 
	while labels_vbox_node.get_child_count() < get_button_count():
		var new_label_node = Label.new()
		new_label_node.add_theme_font_override("font", preload("res://fonts/normal/normal.png"))
		labels_vbox_node.add_child(new_label_node)
	
	while labels_vbox_node.get_child_count() > get_button_count():
		labels_vbox_node.get_child(0).queue_free()
	
	for i in button_names.size():
		var label_node = get_button_label(i)
		label_node.text = button_names[i]
	

func select():
	menu_selected.emit()

func _process(delta):
	if active:
		if Input.is_action_just_pressed("aim_down"):
			move_down()
		elif Input.is_action_just_pressed("aim_up"):
			move_up()
		elif Input.is_action_just_pressed("select"):
			select()


func move(direction:int) -> void:
	direction = sign(direction)
	
	if direction == 0:
		return
	
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


func deactivate():
	active = false
	update_active_effect()
