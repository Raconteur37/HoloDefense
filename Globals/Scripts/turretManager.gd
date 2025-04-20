extends Node

var unlockedTurrets = ["Arrow Turret","Mini Sentry Turret","Energizer Turret","Railgun Turret","Royal Turret","Flame Turret"
,"Reaper Turret","Firework Turret","Spider Turret","Tesla Turret","Seismic Turret","Gold Mine Turret"
,"Automated Sentry Turret","Voodoo Turret","Zombie Turret","Medic Turret"]

var allTurrets = ["Arrow Turret","Mini Sentry Turret","Energizer Turret","Railgun Turret","Royal Turret","Flame Turret"
,"Reaper Turret","Firework Turret","Spider Turret","Tesla Turret","Seismic Turret","Gold Mine Turret"
,"Automated Sentry Turret","Voodoo Turret","Zombie Turret","Medic Turret"]

func getTurretByName(turretName):

	match turretName:

		"Arrow Turret":
			return load("res://Turret Scenes/Arrow Turret.tscn")
		"Mini Sentry Turret":
			return load("res://Turret Scenes/Mini Sentry Turret.tscn")
		"Energizer Turret":
			return load("res://Turret Scenes/Energizer Turret.tscn")
		"Railgun Turret":
			return load("res://Turret Scenes/Railgun Turret.tscn")
		"Reaper Turret":
			return load("res://Turret Scenes/Reaper Turret.tscn")
		"Royal Turret":
			return load("res://Turret Scenes/Royal Turret.tscn")
		"Flame Turret":
			return load("res://Turret Scenes/Flame Turret.tscn")
		"Firework Turret":
			return load("res://Turret Scenes/Firework Turret.tscn")
		"Spider Turret":
			return load("res://Turret Scenes/Spider Turret.tscn")
		"Tesla Turret":
			return load("res://Turret Scenes/Tesla Turret.tscn")
		"Seismic Turret":
			return load("res://Turret Scenes/Seismic Turret.tscn")
		"Gold Mine Turret":
			return load("res://Turret Scenes/Gold Mine Turret.tscn")
		"Automated Sentry Turret":
			return load("res://Turret Scenes/Automated Sentry Turret.tscn")
		"Voodoo Turret":
			return load("res://Turret Scenes/Voodoo Turret.tscn")
		"Zombie Turret":
			return load("res://Turret Scenes/Zombie Turret.tscn")
		"Medic Turret":
			return load("res://Turret Scenes/Medic Turret.tscn")

func findTurretTexture(turretName):

	match turretName:

		"Arrow Turret":
			return load("res://Textures/Turrets/Arrow Turret/ArrowTurret.png")
		"Mini Sentry Turret":
			return load("res://Textures/Turrets/Mini Sentry Turret/MiniSentryTurret.png")
		"Energizer Turret":
			return load("res://Textures/Turrets/Energizer Turret/Energizer Turret.png")
		"Railgun Turret":
			return load("res://Textures/Turrets/Railgun Turret/RailgunTurret.png")
		"Reaper Turret":
			return load("res://Textures/Turrets/Reaper Turret/ReaperTurret.png")
		"Royal Turret":
			return load("res://Textures/Turrets/Royal Turret/RoyalTurret.png")
		"Flame Turret":
			return load("res://Textures/Turrets/Flame Turret/Flame Turret.png")
		"Firework Turret":
			return load("res://Textures/Turrets/Firework Turret/Firework Turret Bottom.png")
		"Spider Turret":
			return load("res://Textures/Turrets/Spider Turret/Spider Turret.png")
		"Tesla Turret":
			return load("res://Textures/Turrets/Tesla Turret/Tesla Turret.png")
		"Seismic Turret":
			return load("res://Textures/Turrets/Seismic Turret/SeismicTurret.png")
		"Gold Mine Turret":
			return load("res://Textures/Turrets/Gold Mine Turret/Gold Mine Turret.png")
		"Automated Sentry Turret":
			return load("res://Textures/Turrets/Automated Sentry Turret/AutomatedSentryTurret.png")
		"Voodoo Turret":
			return load("res://Textures/Turrets/Voodoo Turret/Voodoo Turret.png")
		"Zombie Turret":
			return load("res://Textures/Turrets/Zombie Turret/Zombie Turret.png")
		"Medic Turret":
			return load("res://Textures/Turrets/Healing Turret/Healing Turret.png")
