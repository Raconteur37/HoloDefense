extends Node2D


func removeEffect(victim,effectName):
	if victim.effects.has(effectName):
		victim.effects[effectName].queue_free()
		victim.effects.erase(effectName)
	#if effectName == "Curse":
	#	victim.curseDamageAmp = 0

func applyFireEffect(victim,attacker,damage,time):
	if victim.effects.has("Fire"):
		victim.effects.get("Fire").restartTime(time)
		return
	var fireScene = load("res://Globals/Scene/Effects/Fire.tscn")
	var effectScene = fireScene.instantiate()
	effectScene.applyData(attacker,victim,damage,time)
	victim.add_child(effectScene)


func applyPoisonEffect(victim,turret,damage,time):
	if victim.effects.has(EffectClass.Effect.POISON):
		victim.effects.get(EffectClass.Effect.POISON).resetDuration(time)
		return
	var effectScene = load("res://Globals/Scene/Effects/Effect.tscn")
	effectScene = effectScene.instantiate()
	effectScene.effect = EffectClass.Effect.POISON
	effectScene.tickTime = 0.3
	effectScene.duration = time
	effectScene.enemy = victim
	effectScene.turretApplier = turret
	effectScene.damage = damage
	victim.effects[EffectClass.Effect.POISON] = effectScene
	victim.add_child(effectScene)

func applyCurseEffect(victim,turret,time):
	if victim.effects.has("Curse"):
		victim.effects.get("Curse").restartTime(time)
		return
	var curseScene = load("res://Globals/Scene/Effects/Curse.tscn")
	var effectScene = curseScene.instantiate()
	effectScene.applyData(turret,victim,time)
	victim.add_child(effectScene)
