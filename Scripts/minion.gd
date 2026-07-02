extends CharacterBody2D

class_name Minion

var turretOwner : Turret

var maxHealth : float
var minionName : String
var attackTime : float
var speed : float
var health : float
var damage : float
var sprite

var currentParticlesMap = {}

var effects : Dictionary = {}

var ignitionRounds : bool = false
var ignitionRoundsBurnTime = 0
var ignitionRoundsBurnDamage = 0

var id : MinionID

enum MinionID {
	NONE,
	KNIGHT,
	ARCHER,
	BARD
}

func death():
	turretOwner.removeMinion(self)
	queue_free()

func applyProjectileModifiers(proj) -> void:
	if ignitionRounds:
		proj.burn = true 
		proj.burnTime = ignitionRoundsBurnTime
		proj.burnDamage = ignitionRoundsBurnDamage

func giveIgnitionRounds(time, burnTime, burnDamage):
	if not currentParticlesMap.has("Ignition Rounds"):
		ParticleManager.playIgnitionRoundsParticle(self)
	if effects.has("Ignition Rounds"):
		effects.get("Ignition Rounds").wait_time = time
		effects.get("Ignition Rounds").start()
	else:
		var timer = Timer.new()
		
		add_child(timer) 
		
		ignitionRoundsBurnDamage = burnDamage
		ignitionRoundsBurnTime = burnTime
		ignitionRounds = true
		
		timer.wait_time = time
		timer.one_shot = true
		timer.timeout.connect(removeIgnitionRounds)
		timer.start()
		
		effects["Ignition Rounds"] = timer

func removeIgnitionRounds():
	if currentParticlesMap.has("Ignition Rounds"):
		currentParticlesMap.get("Ignition Rounds").queue_free()
		currentParticlesMap.erase("Ignition Rounds")
	
	if effects.has("Ignition Rounds"):
		var timer = effects.get("Ignition Rounds")
		if is_instance_valid(timer):
			timer.queue_free()
			
	effects.erase("Ignition Rounds")
	ignitionRounds = false
	ignitionRoundsBurnDamage = 0
	ignitionRoundsBurnTime = 0
