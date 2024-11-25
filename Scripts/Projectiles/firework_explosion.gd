extends Node2D

var shotNumber = 1
var explosionRadius = 10 # This will be the particle emission sphere radius
var explosionDamage = 10
var turretOwner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if shotNumber == 3:
		$FireworkExplosion.texture = load("res://Particle Scenes/Projectile/Firework/red_explosion.png")
	if shotNumber == 2:
		$FireworkExplosion.texture = load("res://Particle Scenes/Projectile/Firework/white_explosion.png")
	if shotNumber == 1:
		$FireworkExplosion.texture = load("res://Particle Scenes/Projectile/Firework/blue_explosion.png")
	$Area2D/CollisionShape2D.shape.radius = explosionRadius
	$FireworkExplosion.emission_sphere_radius = explosionRadius
	$FireworkExplosion.amount = explosionRadius * .6
	await get_tree().create_timer(.05).timeout
	for x in $Area2D.get_overlapping_areas():
		if x.get_parent().is_in_group("Enemy"):
			x.get_parent().takeDamage(explosionDamage,turretOwner)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.takeDamage(explosionDamage,turretOwner)


func _on_timer_timeout() -> void:
	queue_free()
