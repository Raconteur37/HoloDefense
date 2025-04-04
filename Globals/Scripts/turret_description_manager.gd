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
	
	animationPlayer.play("Appear")
	
	nameLabel.text = str(turret.getName())
	turretImage.texture = GameManager.findTurretTexture(turret.getName())
	
	if turret.get("health") != null:
		healthBar.max_value = turret.maxHealth
		healthBar.value = turret.health
		healthRichLabelText.text = "[img=32x32]res://Textures/Icons/Health Icon.png[/img]     " + str(turret.health) + "/" + str(turret.maxHealth)
	if turret.get("blahblah") != null: # SHould be armor
		var marginContainer = MarginContainer.new()
		var label = Label.new()
		var richLabel = RichTextLabel.new()
		richLabel.bbcode_enabled = true
		richLabel.fit_content = true
		richLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		richLabel.text = "[img=32x32]res://Textures/Icons/Shield Icon.png[/img]"
		var color = Color.LIGHT_SLATE_GRAY
		label.set("theme_override_colors/font_color",color)
		label.text = str(turret.armor)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		marginContainer.add_child(label)
		marginContainer.add_child(richLabel)
		gridContainer.add_child(marginContainer)
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
		
	
	scene.show()
	
	
	
	

func close():
	queue_free()
