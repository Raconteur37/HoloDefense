extends Control


func applyTurret(turret):
	$PanelContainer/MarginContainer/GridContainer/LabelMarginContainer/MaxHealthLabel.text = "Max Health: " + str(turret.maxHealth)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer/CurrentHealthLabel.text = "Health: " + str(turret.health)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer3/AttackRangeLabel.text = "Attack Range: " + str(turret.attackRange)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer4/ReloadTimeLabel.text = "Summon Time: " + str(turret.summonTime)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer6/ArmorLabel.text ="Armor: " + str(turret.armor)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer8/MaxKnightsLabel.text = "Max Knights " + str(turret.maxKnights)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer2/KnightHealthLabel.text = "Knight Health: " + str(turret.knightHealth)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer7/KnightDamageLabel.text = "Knight Damage: " + str(turret.knightDamage)
	$AnimationPlayer.play("Open")

func close():
	queue_free()
