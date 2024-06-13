extends Node

enum InputMode {
	KEYBOARD_AND_MOUSE,
	CONTROLLER
}

var default_ip:String = "LOCALHOST"
var default_port:int = 25565
var input_mode:int = InputMode.KEYBOARD_AND_MOUSE
var accept_input:bool = true


func _ready():
	load_settings()


func load_settings():
	var config_file:ConfigFile = ConfigFile.new()
	var err:int = config_file.load("user://settings.cfg")
	
	if err != OK:
		return
	
	input_mode = config_file.get_value("gameplay", "input_mode", input_mode)
	default_ip = config_file.get_value("gameplay", "default_ip", default_ip)
	default_port = config_file.get_value("gameplay", "default_port", default_port)
	
	DisplayServer.window_set_mode(config_file.get_value("visual", "window_mode", DisplayServer.WINDOW_MODE_WINDOWED))
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), config_file.get_value("audio", "volume_db", -6))
	
	Network.my_information.username = config_file.get_value("cosmetics", "username", Network.my_information.username)
	Network.my_information.hat = config_file.get_value("cosmetics", "hat", Network.my_information.hat)
	Network.my_information.color = config_file.get_value("cosmetics", "color", Network.my_information.color)
	

func save_settings():
	var config_file:ConfigFile = ConfigFile.new()
	
	config_file.set_value("gameplay", "input_mode", input_mode)
	config_file.set_value("gameplay", "default_ip", default_ip)
	config_file.set_value("gameplay", "default_port", default_port)
	
	config_file.set_value("visual", "window_mode", DisplayServer.window_get_mode(0))
	
	config_file.set_value("audio", "volume_db", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	
	config_file.set_value("cosmetics", "username", Network.my_information.username)
	config_file.set_value("cosmetics", "hat", Network.my_information.hat)
	config_file.set_value("cosmetics", "color", Network.my_information.color)
	
	config_file.save("user://settings.cfg")


func _notification(what):
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			accept_input = false
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			accept_input = true


func change_input_mode_to_controller():
	input_mode = InputMode.CONTROLLER


func change_input_mode_to_keyboard_and_mouse():
	input_mode = InputMode.KEYBOARD_AND_MOUSE
