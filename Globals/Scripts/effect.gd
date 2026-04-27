extends Node2D
class_name EffectClass

var tickTimer : Timer
var durationTimer : Timer

var tickTime : float
var duration : float

enum Effect {
	NONE,
	POISON,
	CURSE,
	BURN
}

var particleEffect

var effectName
var damage
var turretApplier = null # Need this to be null in case I forgot to apply the turret
var enemy = null # same for this

var effect : Effect

func _ready() -> void:
	durationTimer = $"Duration Timer"
	tickTimer = $"Tick Timer"
	
	tickTimer.wait_time = tickTime
	tickTimer.start()
	
	durationTimer.wait_time = duration
	durationTimer.start()
	
	setParticle()

func _on_tick_timer_timeout() -> void:
	match effect:
		
		EffectClass.Effect.POISON:
			EntityManager.enemyTakeDamage(buildPacket(), enemy)
	
	particleEffect.global_position = enemy.global_position
	

func resetDuration(time):
	durationTimer.wait_time = time
	durationTimer.start()

func buildPacket() -> DamagePacket:
	var fx = []
	var fxData = {}

	match effect:
		
		EffectClass.Effect.POISON:
			fx.append(Effect.POISON)
	
		EffectClass.Effect.BURN:
			fx.append(Effect.BURN)
	
	#print(damage,turretApplier,enemy)
	return DamagePacket.new(damage, DamagePacket.Type.EFFECT, turretApplier, fx, fxData)

func _on_duration_timer_timeout() -> void:
	EffectManager.removeEffect(enemy,effect)
	queue_free()

func setParticle():
	match effect:
		
		EffectClass.Effect.POISON:
			particleEffect = load("res://Particle Scenes/Effects/Poison/poison.tscn")
			particleEffect = particleEffect.instantiate()
			add_child(particleEffect)

		EffectClass.Effect.BURN:
			particleEffect = load("res://Particle Scenes/Effects/fire.tscn")
			particleEffect.instantiate()
			add_child(particleEffect)
