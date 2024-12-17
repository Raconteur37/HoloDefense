extends Node

var turretImageContainer
var nameLabel
var marginContainer
var gridContainer
var scene


func _ready() -> void:
	scene = $"."
	turretImageContainer = $CanvasLayer/PanelContainer/MarginContainer/GridContainer/TurretImageContainer/PanelContainer/TurretImage
	nameLabel = $"CanvasLayer/PanelContainer/MarginContainer/GridContainer/LabelMarginContainer/Name Label"
	marginContainer = $CanvasLayer/PanelContainer/MarginContainer/GridContainer/MarginContainer
	gridContainer = $CanvasLayer/PanelContainer/MarginContainer/GridContainer

func buildContainer(turret):
	
	nameLabel.text = str(turret.getName())
	turretImageContainer.texture = GameManager.findTurretTexture(turret.getName())
	
	if turret.get("health") != null:
		marginContainer.get_child(0).text = str(turret.health)
	if turret.get("armor") != null:
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
		var marginContainer = MarginContainer.new()
		var label = Label.new()
		var richLabel = RichTextLabel.new()
		richLabel.bbcode_enabled = true
		richLabel.fit_content = true
		richLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		richLabel.text = "[img=32x32]res://Textures/Icons/Damage Icon.png[/img]"
		var color = Color.FIREBRICK
		label.set("theme_override_colors/font_color",color)
		label.text = str(turret.armor)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		marginContainer.add_child(label)
		marginContainer.add_child(richLabel)
		gridContainer.add_child(marginContainer)
	if turret.get("reloadTime") != null:
		var marginContainer = MarginContainer.new()
		var label = Label.new()
		marginContainer.add_child(label)
		var color = Color.KHAKI
		label.set("theme_override_colors/font_color",color)
		label.text = "Reload Time: " + str(turret.reloadTime)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gridContainer.add_child(marginContainer)
	if turret.get("projectileSpeed") != null:
		var marginContainer = MarginContainer.new()
		var label = Label.new()
		marginContainer.add_child(label)
		var color = Color.NAVAJO_WHITE
		label.set("theme_override_colors/font_color",color)
		label.text = "Projectile Spd.: " + str(turret.projectileSpeed)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gridContainer.add_child(marginContainer)
	if turret.get("attackRange") != null:
		var marginContainer = MarginContainer.new()
		var label = Label.new()
		marginContainer.add_child(label)
		var color = Color.DEEP_SKY_BLUE
		label.set("theme_override_colors/font_color",color)
		label.text = "Range: " + str(turret.attackRange)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gridContainer.add_child(marginContainer)
	if turret.get("explosionDamage") != null:
		var dupe = marginContainer.duplicate()
		var label = dupe.get_child(0)
		label.text = "Explosion Damage: " + str(turret.explosionDamage)
		gridContainer.add_child(dupe)
	if turret.get("explosionRadius") != null:
		var dupe = marginContainer.duplicate()
		var label = dupe.get_child(0)
		label.text = "Explosion Radius: " + str(turret.explosionRadius)
		gridContainer.add_child(dupe)
	if turret.get("pierce") != null:
		var dupe = marginContainer.duplicate()
		var label = dupe.get_child(0)
		label.text = "Pierce: " + str(turret.pierce)
		gridContainer.add_child(dupe)
		
	
	scene.show()
	
	
	
	

func close():
	queue_free()
