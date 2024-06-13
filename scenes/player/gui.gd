extends CanvasLayer

@onready var flash_rect_node = $FlashRect
@onready var player_node := $".."
@onready var ammo_node := $StatusBar/Ammo
@onready var wide_shot_particles_node := $StatusBar/WideShotParticles
@onready var rage_meter_node := $RageMeter
@onready var bonus_ammo_nodes:Array = [
	$StatusBar/BonusAmmoBackground,
	$StatusBar/BonusAmmoNinePatch,
	$StatusBar/BonusAmmo
]

func flash():
	flash_rect_node.color.a = 0.4

func _process(delta):
	
	var has_bonus_ammo:bool = player_node.ammo_manager_node.get_bonus_ammo() > 0
	for bonus_ammo_node in bonus_ammo_nodes:
		bonus_ammo_node.visible = has_bonus_ammo
	
	if has_bonus_ammo:
		rage_meter_node.rotation = randf() * 0.025
	else:
		rage_meter_node.rotation = 0.0
	
	flash_rect_node.color.a = max(0.0, flash_rect_node.color.a - delta * 10)
	
	wide_shot_particles_node.emitting = player_node.wide_spread
	
	if player_node.wide_spread:
		#ammo_hbox_node.rotation = randf() * 0.25 - 0.125
		
		for ammo_icon in ammo_node.get_children():
			ammo_icon.rotation = randf() * 0.8 - 0.4
		
	else:
		#ammo_hbox_node.rotation = 0.0
		
		for ammo_icon in ammo_node.get_children():
			ammo_icon.rotation = 0.0
		
