extends TextureRect


@onready var canvas = $".."


func _on_visibility_changed() -> void:
	if canvas != null:
		if canvas.visible:
			mouse_filter = Control.MOUSE_FILTER_PASS
		else:
			mouse_filter = Control.MOUSE_FILTER_STOP
