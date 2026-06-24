extends Node

enum ExplosionType {
	NONE,
	FIREWORK_TURRET,
}

var explosionType
var damage : float = 0
var radius: float = 0
var turretApplier : Turret
var location
var particle

@onready var explosionParticlesTexture = {Turret.TurretID.FIREWORK_TURRET : {
	"scene" : preload("res://Particle Scenes/Projectile/Firework/firework_explosion.tscn"),
	"baseRadius" : 25},
	Turret.TurretID.ENERGIZER_TURRET : {
		"scene" : preload("res://Particle Scenes/Turrets/Energizer Turret/energizeExplosion.tscn"),
		"baseRadius" : TurretManager.getTurretStat(Turret.TurretID.ENERGIZER_TURRET,"explosionRange")
	}
}

func summonExplosion(turret : Turret, position : Vector2, fxData : Dictionary):
	turretApplier = turret
	location = position
	
	particle = explosionParticlesTexture.get(turretApplier.turretID).get("scene")
	
	setExplosionDetails(turretApplier)
	
	# this is where we go beyond just explosion and apply poison or curse or whatever
	if fxData.has("explosionDamage"):
		damage = fxData.get("explosionDamage")
	if fxData.has("explosionRadius"):
		radius = fxData.get("explosionRadius")

	spawnExplosionArea()

# Can use this to check certain levels or special events
func setExplosionDetails(turret):
	match turret.turretID:
		
		Turret.TurretID.FIREWORK_TURRET:
			explosionType = ExplosionType.FIREWORK_TURRET
			if turretApplier.level >= 2:
				print("add extra fx you bum")
	explosionType = ExplosionType.NONE


func spawnExplosionArea() -> void:

	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	area.add_child(shape)
	area.collision_mask = 4
	area.collision_layer = 1

	var scene = get_tree().root.find_child("EnemyNodeHolder", true, false)

	scene.add_child(area)
	area.global_position = location


	if particle:
		var p = particle.instantiate()
		scene.add_child(p)
		p.global_position = location
		var scaleFactor = radius / explosionParticlesTexture.get(turretApplier.turretID).get("baseRadius")
		p.scale = Vector2(scaleFactor, scaleFactor)
		p.amount = int(p.amount * scaleFactor)
		p.emitting = true


	await get_tree().create_timer(.05).timeout

	# do the special posion or curse or whatever here
	for body in area.get_overlapping_areas():
		#print("area: ", body.name, " | owner: ", body.owner, " | parent: ", body.get_parent())
		var enemy = body.get_parent()
		#print(enemy.enemyName)
		if enemy.is_in_group("Enemy"):
			EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.EXPLOSION, turretApplier, [], {}), enemy)

	await get_tree().create_timer(2.0).timeout
	area.queue_free()
