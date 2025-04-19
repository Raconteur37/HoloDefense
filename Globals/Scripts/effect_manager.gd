extends Node2D


func removeEffect(enemy,effectName):
	if enemy.effects.has(effectName):
		enemy.effects[effectName].queue_free()
		enemy.effects.erase(effectName)
	if effectName == "Curse":
		enemy.curseDamageAmp = 0

func applyFireEffect(victim,turret,damage,time):
	if victim.effects.has("Fire"):
		victim.effects.get("Fire").restartTime(time)
		return
	var fireScene = load("res://Globals/Scene/Effects/Fire.tscn")
	var effectScene = fireScene.instantiate()
	effectScene.applyData(turret,victim,damage,time)
	victim.add_child(effectScene)


func applyPoisonEffect(victim,turret,damage,time):
	if victim.effects.has("Poison"):
		victim.effects.get("Poison").restartTime(time)
		return
	var poisonScene = load("res://Globals/Scene/Effects/Poison.tscn")
	var effectScene = poisonScene.instantiate()
	effectScene.applyData(turret,victim,damage,time)
	victim.add_child(effectScene)

func applyCurseEffect(victim,turret,time):
	if victim.effects.has("Curse"):
		victim.effects.get("Curse").restartTime(time)
		return
	var curseScene = load("res://Globals/Scene/Effects/Curse.tscn")
	var effectScene = curseScene.instantiate()
	effectScene.applyData(turret,victim,time)
	victim.add_child(effectScene)
