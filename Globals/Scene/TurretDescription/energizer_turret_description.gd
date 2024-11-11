extends Control

func applyTurret(turret):
	$PanelContainer/MarginContainer/GridContainer/LabelMarginContainer/MaxHealthLabel.text = "Max Health: " + str(turret.maxHealth)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer/CurrentHealthLabel.text = "Health: " + str(turret.health)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer7/MaxTurretsEnergizedLabel.text = "Max Turrets Energized: " + str(turret.maxTurretsEnergized)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer8/EnergizedTimeLabel.text = "Energize Time: " + str(turret.energizeTime)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer10/TurretsEnergizedLabel.text = "Turrets Energized: " + str(turret.turretsEnergized)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer9/RangeLabel.text = "Range: " + str(turret.attackRange)
	$PanelContainer/MarginContainer/GridContainer/MarginContainer2/DamageLabel.text = "Damage Buff: " + str(turret.energizerDamageBuff) + "%"
	$PanelContainer/MarginContainer/GridContainer/MarginContainer3/AttackRangeLabel.text = "Range Buff: " + str(turret.energizerAttackRangeBuff) + "%"
	$PanelContainer/MarginContainer/GridContainer/MarginContainer4/ReloadTimeLabel.text = "Reload Time Buff: " + str(turret.energizerReloadTimeBuff) + "%"
	$PanelContainer/MarginContainer/GridContainer/MarginContainer5/ProjectileSpeedLabel.text = "Projectile Spd Buff: " + str(turret.energizerProjctileSpeedBuff) + "%"
	$PanelContainer/MarginContainer/GridContainer/MarginContainer6/ArmorLabel.text ="Armor: " + str(turret.armor)
	$AnimationPlayer.play("Open")

func close():
	queue_free()
