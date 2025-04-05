extends Control

func buildStatInformation(slot : Rect2i, type):

	var panelLabel = $CanvasLayer/PopupPanel/MainLabel
	
	var mouse_pos = get_viewport().get_mouse_position()
	var correction
	
	if mouse_pos.x <= get_viewport_rect().size.x/2:
		correction = Vector2i(slot.size.x, 0)
	else:
		correction = Vector2i(%PopupPanel.size.x, 0)
	
	match type:
		
		"damage":
			panelLabel.text = "Damage"
		"reloadTime":
			panelLabel.text = "Reload Speed"
		"attackRange":
			panelLabel.text = "Range"
		"projectileSpeed":
			panelLabel.text = "Projectile Speed"
		"maxTurretsEnergized":
			panelLabel.text = "Turrets Energized"
		"energizeTime":
			panelLabel.text = "Time it takes to energize a turret"
		"energizerDamageBuff":
			panelLabel.text = "Damage Buff"
		"energizerReloadTimeBuff":
			panelLabel.text = "Reload Time Buff"
		"energizerAttackRangeBuff":
			panelLabel.text = "Attack Range Buff"
		"energizerProjctileSpeedBuff":
			panelLabel.text = "Projectile Speed Buff"
		"explosionDamage":
			panelLabel.text = "Explosion Damage"
		"explosionRadius":
			panelLabel.text = "Explosion Radius"
		"fireDamage":
			panelLabel.text = "Fire Damage"
		"fireTime":
			panelLabel.text = "Fire Duration"
		"pierce":
			panelLabel.text = "Pierce"
		"executionChance":
			panelLabel.text = "Execution Chance"
		"poisonChance":
			panelLabel.text = "Poison Chance"
		"poisonDamage":
			panelLabel.text = "Poison Damage"
		"poisonDuration":
			panelLabel.text = "Poison Duration"
			
	%PopupPanel.popup(Rect2i(slot.position + correction, %PopupPanel.size))

func exitPopup():
	%PopupPanel.hide()
