extends Node2D


func removeEffect(victim,effectName):
	if victim.effects.has(effectName):
		victim.effects[effectName].queue_free()
		victim.effects.erase(effectName)
	if effectName == "Curse":
		victim.curseDamageAmp = 0

func applyFireEffect(victim,attacker,damage,time):
	if victim.effects.has("Fire"):
		victim.effects.get("Fire").restartTime(time)
		return
	var fireScene = load("res://Globals/Scene/Effects/Fire.tscn")
	var effectScene = fireScene.instantiate()
	effectScene.applyData(attacker,victim,damage,time)
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
