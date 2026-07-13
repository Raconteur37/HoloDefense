extends Node2D

@onready var theShape = $Area2D/CollisionShape2D
@onready var lifeTimer = $Timer
@onready var tickTimer = $tickTimer
@onready var particle = $CPUParticles2D
@onready var animationPlayer = $AnimationPlayer

var enemiesInRange = []


var turretApplier
var ignitionTime
var ignitionDamage
var lifeTime
var radius

func buildPool(turret, igTime, igDamage, life, rad):
	turretApplier = turret
	ignitionTime = igTime
	ignitionDamage = igDamage
	lifeTime = life
	radius = rad
	particle.emission_sphere_radius = radius
	
	theShape.shape = theShape.shape.duplicate() 
	theShape.shape.radius = radius
	
	lifeTimer.wait_time = lifeTime - 1
	lifeTimer.start()


func _on_tick_timer_timeout() -> void:
	for enemy in enemiesInRange:
		EffectManager.applyBurnEffect(enemy,turretApplier,ignitionDamage,ignitionTime)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		enemiesInRange.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		enemiesInRange.erase(body)


func _on_timer_timeout() -> void:
	animationPlayer.play("FadeOut")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeOut":
		queue_free()
