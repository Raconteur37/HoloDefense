class_name DamagePacket

extends Resource

enum Type { PROJECTILE, EXPLOSION, BEAM, TURRET, EFFECT, MINION }

var damage: float
var type: Type
var source          # The turret/node that caused it, can be null
var effects: Array  # e.g. ["poison", "curse", "execution"]
var effectData: Dictionary  # e.g. { "poisonDamage": 5, "poisonTime": 3.0 }

func _init(dmg: int, t: Type, src = null, fx: Array = [], fxData: Dictionary = {}):
	damage = dmg
	type = t
	source = src
	effects = fx
	effectData = fxData
