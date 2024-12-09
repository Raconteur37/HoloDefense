extends Node

var turretImageContainer
var nameLabel
var marginContainer
var gridContainer
var scene


func _ready() -> void:
	scene = $"."
	turretImageContainer = $PanelContainer/MarginContainer/GridContainer/TurretImageContainer/PanelContainer/TurretImage
	nameLabel = $"PanelContainer/MarginContainer/GridContainer/LabelMarginContainer/Name Label"
	marginContainer = $PanelContainer/MarginContainer/GridContainer/MarginContainer
	gridContainer = $PanelContainer/MarginContainer/GridContainer

func buildContainer(turret):
	
	nameLabel.text = str(turret.getName())
	turretImageContainer.texture = findTurretTexture(turret.getName())
	
	if turret.get("health") != null:
		marginContainer.get_child(0).text = "Health: " + str(turret.health)
	if turret.get("armor") != null:
		var dupe = marginContainer.duplicate()
		var label = dupe.get_child(0).duplicate()
		dupe.remove_child(get_child(0))
		dupe.add_child(label)
		label.set("custom_colors/font_color", Color(0, 1, 0))  # Set to green
		label.text = "Armor: " + str(turret.armor)
		gridContainer.add_child(dupe)
	if turret.get("damage") != null:
		var dupe = marginContainer.duplicate()
		var label = dupe.get_child(0)
		label.label_settings.font_color
		label.text = "Damage: " + str(turret.damage)
		gridContainer.add_child(dupe)
	if turret.get("reloadTime") != null:
		var dupe = marginContainer.duplicate()
		var label = dupe.get_child(0)
		label.text = "Reload Time: " + str(turret.reloadTime)
		gridContainer.add_child(dupe)
	if turret.get("projectileSpeed") != null:
		var dupe = marginContainer.duplicate()
		var label = dupe.get_child(0)
		label.text = "Projectile Spd.: " + str(turret.projectileSpeed)
		gridContainer.add_child(dupe)
	if turret.get("attackRange") != null:
		var dupe = marginContainer.duplicate()
		var label = dupe.get_child(0)
		label.text = "Range: " + str(turret.attackRange)
		gridContainer.add_child(dupe)
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
	
	
func findTurretTexture(turretName):
	
	match turretName:
		
		"Spider Turret":
			return load("res://Textures/Turrets/Spider Turret/Spider Turret.png")
	
	

func close():
	queue_free()
