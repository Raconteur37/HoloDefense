class_name Explosion
extends Area2D

var damage : float
var turretApplier : Turret
var location

const explosionParticles = {Turret.TurretID.FIREWORK_TURRET : preload("res://Particle Scenes/Projectile/Firework/firework_explosion.tscn")} # Will be turret ID and the particle location


func _init(turret : Turret) -> void:
	turretApplier = turret
	
	var particle = explosionParticles.get(turretApplier.turretID)
	
