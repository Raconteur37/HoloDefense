extends RigidBody2D

var shooter
var damage
var explosionDmg
var explosionSize
var shotNumber
var enterEffect = true

func _on_despawn_timer_timeout() -> void:
	queue_free()
	
func playEnterEffect(enemy):
	var particle = load("res://Particle Scenes/Projectile/Firework/firework_explosion.tscn")
	var activeParticle = particle.instantiate()
	activeParticle.turretOwner = shooter
	activeParticle.shotNumber = shotNumber
	activeParticle.explosionRadius = explosionSize
	activeParticle.explosionDamage = explosionDmg
	activeParticle.setPosition(enemy.global_position) 
	activeParticle.find_child("FireworkExplosion").emitting = true
	get_tree().current_scene.add_child(activeParticle)
