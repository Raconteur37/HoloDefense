extends Node

var turretImage
var nameLabel
var marginContainer
var gridContainer
var statGridContainer
var statHbox
var scene
var animationPlayer
var healthBar
var healthRichLabelText

var turret

func _ready() -> void:
	scene = $"."
	turretImage = $"Background Panel/GridContainer/TurretImageContainer/PanelContainer/TurretImage"
	nameLabel = $"Background Panel/GridContainer/LabelMarginContainer/Name Label"
	marginContainer = $"Background Panel/GridContainer/MarginContainer"
	gridContainer = $"Background Panel/GridContainer"
	statGridContainer = $"Background Panel/Stats Grid Container"
	statHbox = $"Background Panel/Stats Grid Container/HBoxContainer"
	animationPlayer = $AnimationPlayer
	healthBar = $"Background Panel/GridContainer/MarginContainer/Health Bar"
	healthRichLabelText = $"Background Panel/GridContainer/MarginContainer/RichTextLabel"

func buildContainer(turret):

	self.turret = turret

	animationPlayer.play("Appear")

	nameLabel.text = str(turret.getName())
	turretImage.texture = TurretManager.findTurretTexture(turret.getName())

	if turret.get("health") != null:
		healthBar.max_value = turret.maxHealth
		healthBar.value = turret.health
		healthRichLabelText.text = "[img=32x32]res://Textures/Icons/Health Icon.png[/img]     " + str(turret.health) + "/" + str(turret.maxHealth)
		healthBar.tint_progress = Color.DEEP_PINK
	if turret.get("armor") != null:
		if turret.armor > 0:
			healthRichLabelText.text = "[img=32x32]res://Textures/Icons/Shield Icon.png[/img]          " + str(turret.armor)
			healthBar.max_value = turret.armor
			healthBar.value = turret.armor
			healthBar.tint_progress = Color.DARK_GRAY
	if turret.get("damage") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("damage",turret)
		statHbox.add_child(statItem)
	if turret.get("reloadTime") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("reloadTime",turret)
		statHbox.add_child(statItem)
	if turret.get("attackRange") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("attackRange",turret)
		statHbox.add_child(statItem)
	if turret.get("projectileSpeed") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("projectileSpeed",turret)
		statHbox.add_child(statItem)
	if turret.get("maxTurretsEnergized") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("maxTurretsEnergized",turret)
		statHbox.add_child(statItem)
	if turret.get("energizeTime") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("energizeTime",turret)
		statHbox.add_child(statItem)
	if turret.get("energizerDamageBuff") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("energizerDamageBuff",turret)
		statHbox.add_child(statItem)
	if turret.get("energizerReloadTimeBuff") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("energizerReloadTimeBuff",turret)
		statHbox.add_child(statItem)
	if turret.get("energizerAttackRangeBuff") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("energizerAttackRangeBuff",turret)
		statHbox.add_child(statItem)
	if turret.get("energizerProjctileSpeedBuff") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("energizerProjctileSpeedBuff",turret)
		statHbox.add_child(statItem)
	if turret.get("explosionDamage") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("explosionDamage",turret)
		statHbox.add_child(statItem)
	if turret.get("explosionRadius") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("explosionRadius",turret)
		statHbox.add_child(statItem)
	if turret.get("pierce") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("pierce",turret)
		statHbox.add_child(statItem)
	if turret.get("fireDamage") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("fireDamage",turret)
		statHbox.add_child(statItem)
	if turret.get("fireTime") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("fireTime",turret)
		statHbox.add_child(statItem)
	if turret.get("executionChance") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("executionChance",turret)
		statHbox.add_child(statItem)
	if turret.get("poisonChance") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("poisonChance",turret)
		statHbox.add_child(statItem)
	if turret.get("poisonDamage") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("poisonDamage",turret)
		statHbox.add_child(statItem)
	if turret.get("poisonDuration") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("poisonDuration",turret)
		statHbox.add_child(statItem)

	scene.show()

func healthUpdate():
	if turret.get("health") != null:
			healthBar.max_value = turret.maxHealth
			healthBar.value = turret.health
			healthRichLabelText.text = "[img=32x32]res://Textures/Icons/Health Icon.png[/img]     " + str(turret.health) + "/" + str(turret.maxHealth)
			healthBar.tint_progress = Color.DEEP_PINK
	if turret.get("armor") != null:
		if turret.armor > 0:
			healthRichLabelText.text = "[img=32x32]res://Textures/Icons/Shield Icon.png[/img]          " + str(turret.armor)
			healthBar.max_value = turret.armor
			healthBar.value = turret.armor
			healthBar.tint_progress = Color.DARK_GRAY

func close():
	queue_free()
