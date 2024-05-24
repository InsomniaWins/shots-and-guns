extends ColorRect

const FULL_HEART_TEXTURE:Texture = preload("res://textures/gui/health_indicator_full.png")
const EMPTY_HEART_TEXTURE:Texture = preload("res://textures/gui/health_indicator_empty.png")

const FULL_AMMO_TEXTURE:Texture = preload("res://textures/gui/ammo_indicator_full.png")
const EMPTY_AMMO_TEXTURE:Texture = preload("res://textures/gui/ammo_indicator_empty.png")

@onready var player_node:CharacterBody2D = $"../.."
@onready var health_manager_node:Node = $"../../HealthManager"
@onready var ammo_manager_node:Node = $"../../AmmoManager"
@onready var hearts_hbox_node:HBoxContainer = $Stats/Hearts
@onready var ammo_hbox_node:HBoxContainer = $Stats/Ammo
@onready var mini_health_indicator_node:HBoxContainer = $"../../UsernameLabel/HealthIndicator"

func update_ammo_indicator():
	
	if !is_node_ready():
		await ready
	
	for i in ammo_manager_node.get_max_ammo():
		
		var indicator_texture_node:TextureRect = ammo_hbox_node.get_child(i)
		
		if i < ammo_manager_node.get_ammo():
			indicator_texture_node.texture = FULL_AMMO_TEXTURE
		else:
			indicator_texture_node.texture = EMPTY_AMMO_TEXTURE


func update_health_indicator():
	
	if !is_node_ready():
		await ready
	
	for i in health_manager_node.get_max_health():
		
		var indicator_texture_node:TextureRect = hearts_hbox_node.get_child(i)
		
		if i < health_manager_node.get_health():
			mini_health_indicator_node.get_child(i).visible = true
			indicator_texture_node.texture = FULL_HEART_TEXTURE
		else:
			mini_health_indicator_node.get_child(i).visible = false
			indicator_texture_node.texture = EMPTY_HEART_TEXTURE
