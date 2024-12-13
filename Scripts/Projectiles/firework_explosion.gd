extends Node2D

var shotNumber = 1
var explosionRadius = 10 # This will be the particle emission sphere radius
var explosionDamage = 10
var turretOwner

var fireworkExplosion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fireworkExplosion = $FireworkExplosion
	if shotNumber == 3:
		fireworkExplosion.texture = load("res://Particle Scenes/Projectile/Firework/red_explosion.png")
	if shotNumber == 2:
		fireworkExplosion.texture = load("res://Particle Scenes/Projectile/Firework/white_explosion.png")
	if shotNumber == 1:
		fireworkExplosion.texture = load("res://Particle Scenes/Projectile/Firework/blue_explosion.png")
	$Area2D/CollisionShape2D.shape.radius = explosionRadius
	fireworkExplosion.emission_sphere_radius = explosionRadius
	fireworkExplosion.amount = explosionRadius * .6
	await get_tree().create_timer(.05).timeout
	for x in $Area2D.get_overlapping_areas():
		if x.get_parent().is_in_group("Enemy"):
			x.get_parent().hit.emit(explosionDamage,turretOwner,x.get_parent(),self)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.hit.emit(explosionDamage,turretOwner,body,self)


func _on_timer_timeout() -> void:
	queue_free()
