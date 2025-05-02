extends Popup


func _on_popup_hide() -> void:
	queue_free()
