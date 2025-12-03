extends Node

var turretImage
var nameLabel
var scene
var animationPlayer
var healthBar
var healthRichLabelText
var statBox

var turret

func _ready() -> void:
	scene = $"."
	turretImage = $"Background Panel/Main HBox/Left Grid Container/VBoxContainer/TurretImageContainer/PanelContainer/TurretImage"
	nameLabel = $"Background Panel/Main HBox/Left Grid Container/VBoxContainer/Name Label"
	statBox = $"Background Panel/Main HBox/Middle Grid Container/MarginContainer/VBoxContainer/MarginContainer/Stats Grid Container"
	animationPlayer = $AnimationPlayer
	healthBar = $"Background Panel/Main HBox/Left Grid Container/VBoxContainer/MarginContainer/Health Bar"
	healthRichLabelText = $"Background Panel/Main HBox/Left Grid Container/VBoxContainer/MarginContainer/RichTextLabel"

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
		#var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		#statItem = statItem.instantiate()
		#statItem.buildStatContainer("damage",turret)
		#statHbox.add_child(statItem)
		var label = Label.new()
		label.text = "Damage: " + str(turret.damage)
		label.add_theme_color_override("font_color", Color.RED)
		label.add_theme_font_size_override("font_size", 10)
		statBox.add_child(label)
	if turret.get("reloadTime") != null:
		#var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		#statItem = statItem.instantiate()
		#statItem.buildStatContainer("reloadTime",turret)
		#statHbox.add_child(statItem)
		var label = Label.new()
		label.text = "Reload Time: " + str(turret.reloadTime) + "s"
		label.add_theme_color_override("font_color", Color.CORAL)
		label.add_theme_font_size_override("font_size", 10)
		statBox.add_child(label)
	if turret.get("attackRange") != null:
		var label = Label.new()
		label.text = "Range: " + str(turret.attackRange)
		label.add_theme_color_override("font_color", Color.SKY_BLUE)
		label.add_theme_font_size_override("font_size", 10)
		statBox.add_child(label)
	if turret.get("projectileSpeed") != null:
		var label = Label.new()
		label.text = "Projectile Speed: " + str(turret.projectileSpeed)
		label.add_theme_color_override("font_color", Color.CADET_BLUE)
		label.add_theme_font_size_override("font_size", 10)
		statBox.add_child(label)
	if turret.get("maxTurretsEnergized") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("maxTurretsEnergized",turret)
		statBox.add_child(statItem)
	if turret.get("energizeTime") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("energizeTime",turret)
		statBox.add_child(statItem)
	if turret.get("energizerDamageBuff") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("energizerDamageBuff",turret)
		statBox.add_child(statItem)
	if turret.get("energizerReloadTimeBuff") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("energizerReloadTimeBuff",turret)
		statBox.add_child(statItem)
	if turret.get("energizerAttackRangeBuff") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("energizerAttackRangeBuff",turret)
		statBox.add_child(statItem)
	if turret.get("energizerProjctileSpeedBuff") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("energizerProjctileSpeedBuff",turret)
		statBox.add_child(statItem)
	if turret.get("explosionDamage") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("explosionDamage",turret)
		statBox.add_child(statItem)
	if turret.get("explosionRadius") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("explosionRadius",turret)
		statBox.add_child(statItem)
	if turret.get("pierce") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("pierce",turret)
		statBox.add_child(statItem)
	if turret.get("fireDamage") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("fireDamage",turret)
		statBox.add_child(statItem)
	if turret.get("fireTime") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("fireTime",turret)
		statBox.add_child(statItem)
	if turret.get("executionChance") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("executionChance",turret)
		statBox.add_child(statItem)
	if turret.get("poisonChance") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("poisonChance",turret)
		statBox.add_child(statItem)
	if turret.get("poisonDamage") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("poisonDamage",turret)
		statBox.add_child(statItem)
	if turret.get("poisonDuration") != null:
		var statItem = load("res://Globals/Scene/TurretDescription/StatisticItem.tscn")
		statItem = statItem.instantiate()
		statItem.buildStatContainer("poisonDuration",turret)
		statBox.add_child(statItem)

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
