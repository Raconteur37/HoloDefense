extends Control

func buildStatInformation(slot : Rect2i, type):
	
	var mouse_pos = get_viewport().get_mouse_position()
	var correction
	
	if mouse_pos.x <= get_viewport_rect().size.x/2:
		correction = Vector2i(slot.size.x, 0)
	else:
		correction = Vector2i(%PopupPanel.size.x, 0)
	
	match type:
		
		"damage":
			$CanvasLayer/PopupPanel/MainLabel.text = "Damage"
		"reloadTime":
			$CanvasLayer/PopupPanel/MainLabel.text = "Reload Speed"
		"attackRange":
			$CanvasLayer/PopupPanel/MainLabel.text = "Range"
		"projectileSpeed":
			$CanvasLayer/PopupPanel/MainLabel.text = "Projectile Speed"
			
	%PopupPanel.popup(Rect2i(slot.position + correction, %PopupPanel.size))

func exitPopup():
	%PopupPanel.hide()
