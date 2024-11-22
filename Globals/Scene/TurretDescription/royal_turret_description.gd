extends Control


func applyTurret(turret):
	$PanelContainer/MarginContainer/GridContainer/LabelMarginContainer/MaxHealthLabel.text = "Max Health: " + str(turret.maxHealth)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer/CurrentHealthLabel.text = "Health: " + str(turret.health)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer3/AttackRangeLabel.text = "Attack Range: " + str(turret.attackRange)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer4/ReloadTimeLabel.text = "Summon Time: " + str(turret.summonTime)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer6/ArmorLabel.text ="Armor: " + str(turret.armor)
	$AnimationPlayer.play("Open")

func close():
	queue_free()
