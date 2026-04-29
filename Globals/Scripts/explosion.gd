class_name Explosion
extends Area2D

enum ExplosionType {
	NONE,
	FIREWORK_TURRET
}

var explosionType
var damage : float
var turretApplier : Turret
var location
var particle
var fx = []
var fxData = {}

const explosionParticles = {Turret.TurretID.FIREWORK_TURRET : preload("res://Particle Scenes/Projectile/Firework/firework_explosion.tscn")} # Will be turret ID and the particle location


func _init(turret : Turret, enemy : Enemy):
	turretApplier = turret
	location = enemy.global_position
	
	particle = explosionParticles.get(turretApplier.turretID)
	
	setExplosionDetails(turretApplier)
	
	
	

# This is where can add it poisoning or whatever the explosion does beyond just damage
func setExplosionDetails(turret):
	match turret.turretID:
		
		Turret.TurretID.FIREWORK_TURRET:
			explosionType = ExplosionType.FIREWORK_TURRET
			if turretApplier.level >= 2:
				print("add extra fx you bum")
	
	explosionType = ExplosionType.NONE
