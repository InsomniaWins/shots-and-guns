extends Node

enum InputMode {
	KEYBOARD_AND_MOUSE,
	CONTROLLER
}

var input_mode:int = InputMode.KEYBOARD_AND_MOUSE
var accept_input:bool = true

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
