extends PanelContainer

var panelType

var entered : bool = false

func buildStatContainer(type,turret):
	
	var texture = $GridContainer/MarginContainer/TextureRect
	var label = $GridContainer/MarginContainer2/Label
	
	match type:
		
		"damage":
			panelType = "damage"
			texture.texture = load("res://Textures/Icons/Damage Icon.png")
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


func _on_mouse_entered() -> void:
	if not entered:
		StatisticPopup.buildStatInformation(Rect2i( Vector2i(global_position), Vector2i(size)),panelType)
		entered = true

func _on_mouse_exited() -> void:
	if entered:
		StatisticPopup.exitPopup()
		entered = false
