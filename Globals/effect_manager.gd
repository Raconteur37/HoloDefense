extends Node2D

var effectData = {}

func _ready() -> void:
	loadEffectData()
	#print(effectData)

func removeEffect(victim : Enemy, effect : EffectClass.Effect):
	if victim.effects.has(effect):
		victim.effects[effect].removeEffect()
		victim.effects[effect].queue_free()
		victim.effects.erase(effect)

func applyBurnEffect(victim,turret,damage,time):
	if checkResetDuration(EffectClass.Effect.BURN,victim,time):
		var effectScene = load("res://Globals/Scene/Effects/Effect.tscn")
		effectScene = effectScene.instantiate()
		effectScene.effect = EffectClass.Effect.BURN
		effectScene.tickTime = getEffectStat(EffectClass.Effect.BURN,"tickTime")
		effectScene.duration = time
		effectScene.enemy = victim
		effectScene.turretApplier = turret
		effectScene.damage = damage
		victim.effects[EffectClass.Effect.BURN] = effectScene
		victim.add_child(effectScene)

func applyStunEffect(victim,turret,time):
	if checkResetDuration(EffectClass.Effect.STUN,victim,time):
		var effectScene = load("res://Globals/Scene/Effects/Effect.tscn")
		effectScene = effectScene.instantiate()
		effectScene.effect = EffectClass.Effect.STUN
		effectScene.duration = time
		effectScene.enemy = victim
		effectScene.turretApplier = turret
		victim.effects[EffectClass.Effect.STUN] = effectScene
		victim.stunned = true
		victim.add_child(effectScene)


func applyPoisonEffect(victim,turret,damage,time):
	if checkResetDuration(EffectClass.Effect.POISON,victim,time):
		var effectScene = load("res://Globals/Scene/Effects/Effect.tscn")
		effectScene = effectScene.instantiate()
		effectScene.effect = EffectClass.Effect.POISON
		effectScene.tickTime = getEffectStat(EffectClass.Effect.POISON,"tickTime")
		effectScene.duration = time
		effectScene.enemy = victim
		effectScene.turretApplier = turret
		effectScene.damage = damage
		victim.effects[EffectClass.Effect.POISON] = effectScene
		victim.add_child(effectScene)

func applyCurseEffect(victim,turret,time,damageAmp):
	if checkResetDuration(EffectClass.Effect.CURSE,victim,time):
		var effectScene = load("res://Globals/Scene/Effects/Effect.tscn")
		effectScene = effectScene.instantiate()
		effectScene.effect = EffectClass.Effect.CURSE
		effectScene.tickTime = getEffectStat(EffectClass.Effect.CURSE,"tickTime")
		effectScene.duration = time
		effectScene.enemy = victim
		effectScene.turretApplier = turret
		effectScene.curseDamageAmplify = damageAmp
		victim.effects[EffectClass.Effect.CURSE] = effectScene
		victim.add_child(effectScene)


func checkResetDuration(effect : EffectClass.Effect, victim, time):
	if victim.effects.has(effect):
		victim.effects.get(effect).resetDuration(time)
		return false
	else:
		return true

func getEffectString(id: EffectClass.Effect) -> String:
	return EffectClass.Effect.keys()[id].to_lower()

func getEffectStat(id: EffectClass.Effect, stat: String, default = -1):
	var key = getEffectString(id)
	if effectData.has(key) and effectData[key].has(stat):
		return effectData[key][stat]
	return default

func loadEffectData():
	var file = FileAccess.open("res://Config/Effects.json", FileAccess.READ)
	if file:
		var json_str = file.get_as_text()
		var json_result = JSON.parse_string(json_str)
		if typeof(json_result) == TYPE_DICTIONARY:
			effectData = json_result
		else:
			push_error("Invalid JSON in Turret Info.json")
	else:
		push_error("Could not open Turret Info.json")
