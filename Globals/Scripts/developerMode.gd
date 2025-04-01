extends Node

var inDevMode : bool = true

func _input(event: InputEvent) -> void:

	if event is InputEventKey and event.is_pressed():

		match event.keycode:
			KEY_F1:
				#if Input.is_key_pressed(KEY_SHIFT):
				if inDevMode:
					inDevMode = false
					print("Exited dev mode")
				else:
					inDevMode = true
					print("Entered dev mode")
