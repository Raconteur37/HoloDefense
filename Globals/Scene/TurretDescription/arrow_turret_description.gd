extends Control


func applyTurret(turret):
	$PanelContainer/MarginContainer/GridContainer/LabelMarginContainer/MaxHealthLabel.text = "Max Health: " + str(turret.maxHealth)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer/CurrentHealthLabel.text = "Health: " + str(turret.health)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer2/DamageLabel.text = "Damage: " + str(turret.damage)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer3/AttackRangeLabel.text = "Attack Range: " + str(turret.attackRange)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer4/ReloadTimeLabel.text = "Reload Time: " + str(turret.reloadTime)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer5/ProjectileSpeedLabel.text = "Projectile Spd: " + str(turret.projectileSpeed)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer6/ArmorLabel.text ="Armor: " + str(turret.armor)

func close():
	queue_free()
