extends Node

enum Hats {
	NONE = -1,
	YELLOW_DOG,
	HAT_BOY,
	PIRATE_BOY,
	PIRATE_GIRL,
	
	ONLINE_FORUM,
	MASTER_CHEF,
	ZAMUS,
	RPG_SWORD_GUY,
	RED_EYED_NINJA,
	LEGEND_GUY,
	LEGEND_GIRL,
	SOLID_PLISKIN,
	VENOM_PLISKIN,
	NAKED_PLISKIN,
	WHEAT_ROBOT,
	WAR_GOD,
	DARK_LORD,
	BOUNTY_HUNTER,
	GREEN_PLUMBER,
	RED_PLUMBER,
	WATER
	
}


var HAT_INFO:Dictionary = {
	Hats.NONE: _new_hat_info(
		"None"
	),
	Hats.YELLOW_DOG: _new_hat_info(
		"Yellow Dog",
		"res://textures/entities/player/hats/yellow_dog.png"
	),
	Hats.HAT_BOY: _new_hat_info(
		"Hat Boy",
		"res://textures/entities/player/hats/hat_boy.png"
	),
	Hats.PIRATE_BOY: _new_hat_info(
		"Pirate Boy",
		"res://textures/entities/player/hats/pirate_boy.png"
	),
	Hats.PIRATE_GIRL: _new_hat_info(
		"Pirate Girl",
		"res://textures/entities/player/hats/pirate_girl.png"
	),
	Hats.ONLINE_FORUM: _new_hat_info(
		"Online Forum",
		"res://textures/entities/player/hats/online_forum.png"
	),
	Hats.MASTER_CHEF: _new_hat_info(
		"Master Chef",
		"res://textures/entities/player/hats/master_chef.png"
	),
	Hats.ZAMUS: _new_hat_info(
		"Zamus",
		"res://textures/entities/player/hats/zamus.png"
	),
	Hats.RPG_SWORD_GUY: _new_hat_info(
		"RPG Sword Guy",
		"res://textures/entities/player/hats/rpg_sword_guy.png"
	),
	Hats.RED_EYED_NINJA: _new_hat_info(
		"Red Eyed Ninja",
		"res://textures/entities/player/hats/red_eyed_ninja.png"
	),
	Hats.LEGEND_GUY: _new_hat_info(
		"Legend Guy",
		"res://textures/entities/player/hats/legend_guy.png"
	),
	Hats.LEGEND_GIRL: _new_hat_info(
		"Legend Girl",
		"res://textures/entities/player/hats/legend_girl.png"
	),
	Hats.SOLID_PLISKIN: _new_hat_info(
		"Solid Pliskin",
		"res://textures/entities/player/hats/solid_pliskin.png"
	),
	Hats.VENOM_PLISKIN: _new_hat_info(
		"Venom Pliskin",
		"res://textures/entities/player/hats/venom_pliskin.png"
	),
	Hats.NAKED_PLISKIN: _new_hat_info(
		"Naked Pliskin",
		"res://textures/entities/player/hats/naked_pliskin.png"
	),
	Hats.WHEAT_ROBOT: _new_hat_info(
		"Wheat Robot",
		"res://textures/entities/player/hats/wheat_robot.png"
	),
	Hats.WAR_GOD: _new_hat_info(
		"War God",
		"res://textures/entities/player/hats/war_god.png"
	),
	Hats.DARK_LORD: _new_hat_info(
		"Dark Lord",
		"res://textures/entities/player/hats/dark_lord.png"
	),
	Hats.BOUNTY_HUNTER: _new_hat_info(
		"Bounty Hunter",
		"res://textures/entities/player/hats/bounty_hunter.png"
	),
	Hats.GREEN_PLUMBER: _new_hat_info(
		"Green Plumber",
		"res://textures/entities/player/hats/green_plumber.png"
	),
	Hats.RED_PLUMBER: _new_hat_info(
		"Red Plumber",
		"res://textures/entities/player/hats/red_plumber.png"
	),
	Hats.WATER: _new_hat_info(
		"Water",
		"res://textures/entities/player/hats/water.png"
	)
}


func _new_hat_info(hat_name:String, texture_path:String = "") -> Dictionary:
	var return_info = {
		"name": hat_name,
		"texture": null
	}
	
	if !texture_path.is_empty():
		return_info["texture"] = load(texture_path)
	
	return return_info


func get_hat_name(hat_index:int) -> String:
	return HAT_INFO[hat_index].name

func get_hat_texture(hat_index:int) -> Texture:
	return HAT_INFO[hat_index].texture


func increment_hat(hat_index:int) -> int:
	hat_index += 1
	
	if !Hats.values().has(hat_index):
		hat_index = -1
	
	return hat_index



func decrement_hat(hat_index:int) -> int:
	hat_index -= 1
	var hat_indices = Hats.values()
	
	if !hat_indices.has(hat_index):
		hat_index = hat_indices[-1]
	
	return hat_index
