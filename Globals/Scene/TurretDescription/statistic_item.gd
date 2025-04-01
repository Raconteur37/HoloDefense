extends PanelContainer

var panelType

var entered : bool = false

func buildStatContainer(type,turret):
	
	var texture = $GridContainer/MarginContainer/TextureRect
	var label = $GridContainer/MarginContainer2/Label
	
	match type:
		
		"damage":
			panelType = "damage"
			#texture.texture = load("res://Textures/Icons/Damage Icon.png")
			label.text = str(turret.damage)
			var color = Color.FIREBRICK
			label.set("theme_override_colors/font_color",color)
		"reloadTime":
			panelType = "reloadTime"
			texture.texture = load("res://Textures/Icons/Reload Icon.png")
			label.text = str(turret.reloadTime)
			var color = Color.DARK_GRAY
			label.set("theme_override_colors/font_color",color)
		"projectileSpeed":
			panelType = "projectileSpeed"
			texture.texture = load("res://Textures/Icons/Projectile Speed Icon.png")
			label.text = str(turret.projectileSpeed)
			var color = Color.CORNFLOWER_BLUE
			label.set("theme_override_colors/font_color",color)
		"attackRange":
			panelType = "attackRange"
			texture.texture = load("res://Textures/Icons/Range Icon.png")
			label.text = str(turret.attackRange)
			var color = Color.ALICE_BLUE
			label.set("theme_override_colors/font_color",color)
		"maxTurretsEnergized":
			panelType = "maxTurretsEnergized"
			texture.texture = load("res://Textures/Icons/Turrets Energized Icon.png")
			label.text = str(turret.turretsEnergized) + "/" + str(turret.maxTurretsEnergized)
			var color = Color.DARK_ORCHID
			label.set("theme_override_colors/font_color",color)
		"energizeTime":
			panelType = "energizeTime"
			texture.texture = load("res://Textures/Icons/Energize Time Icon.png")
			label.text = str(turret.energizeTime)
			var color = Color.INDIGO
			label.set("theme_override_colors/font_color",color)
		"energizerDamageBuff":
			panelType = "energizerDamageBuff"
			texture.texture = load("res://Textures/Icons/Energize Damage Icon.png")
			label.text = str(turret.energizerDamageBuff)
			var color = Color.MEDIUM_VIOLET_RED
			label.set("theme_override_colors/font_color",color)
		"energizerReloadTimeBuff":
			panelType = "energizerReloadTimeBuff"
			texture.texture = load("res://Textures/Icons/Energize Reload Time Icon.png")
			label.text = str(turret.energizerReloadTimeBuff)
			var color = Color.MEDIUM_VIOLET_RED
			label.set("theme_override_colors/font_color",color)
		"energizerAttackRangeBuff":
			panelType = "energizerAttackRangeBuff"
			texture.texture = load("res://Textures/Icons/Energize Range Icon.png")
			label.text = str(turret.energizerAttackRangeBuff)
			var color = Color.MEDIUM_VIOLET_RED
			label.set("theme_override_colors/font_color",color)
		"energizerProjctileSpeedBuff":
			panelType = "energizerProjctileSpeedBuff"
			texture.texture = load("res://Textures/Icons/Energize Projectile Speed.png")
			label.text = str(turret.energizerProjctileSpeedBuff)
			var color = Color.MEDIUM_VIOLET_RED
			label.set("theme_override_colors/font_color",color)

func _on_mouse_entered() -> void:
	if not entered:
		StatisticPopup.buildStatInformation(Rect2i( Vector2i(global_position), Vector2i(size)),panelType)
		entered = true

func _on_mouse_exited() -> void:
	if entered:
		StatisticPopup.exitPopup()
		entered = false
