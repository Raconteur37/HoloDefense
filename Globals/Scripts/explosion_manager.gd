extends Node

enum ExplosionType {
	NONE,
	FIREWORK_TURRET,
	FLAME_TURRET,
	SEISMIC_TURRET,
	VOODOO_TURRET,
	BUBBLE_TURRET,
	MORTAR_TURRET
}

var explosionType
var damage : float = 0
var radius: float = 0
var turretApplier : Turret
var location
var particle

var igniteTime
var igniteDamage

var curseDuration
var curseDamageAmp

var lingeringPoolTime
var lingeringPoolRadius

var knockbackVelocity

var stunTime

@onready var explosionParticlesTexture = {
	Turret.TurretID.FIREWORK_TURRET : {
	"scene" : preload("res://Particle Scenes/Projectile/Firework/firework_explosion.tscn")
	},
	Turret.TurretID.ENERGIZER_TURRET : {
		"scene" : preload("res://Particle Scenes/Turrets/Energizer Turret/energizeExplosion.tscn"),
	},
	Turret.TurretID.FLAME_TURRET : {
		"scene" : preload("res://Particle Scenes/Turrets/Flame Turret/flameExplosion.tscn")
	},
	Turret.TurretID.SEISMIC_TURRET : {
		"scene" : preload("res://Particle Scenes/Turrets/Seismic Turret/SeismicEarthquakeParticle.tscn")
	},
	Turret.TurretID.VOODOO_TURRET : {
		"scene" : preload("res://Particle Scenes/Effects/Curse/Curse Explosion.tscn")
	},
	Turret.TurretID.BUBBLE_TURRET : {
		"scene" : preload("res://Particle Scenes/Effects/Bubble/BubblePop.tscn")
	},
	Enemy.EnemyID.PACKED_CIRCLE : {
		"scene" : preload("res://Particle Scenes/Enemies/packedExplosion.tscn")
	},
	Enemy.EnemyID.MINI_PACKED_CIRCLE : {
		"scene" : preload("res://Particle Scenes/Enemies/miniPackedExplosion.tscn")
	},
	Turret.TurretID.MORTAR_TURRET: {
		"scene" : preload("res://Particle Scenes/Turrets/Mortar Turret/mortarExplosion.tscn")
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
	if fxData.has("igniteTime"):
		igniteTime = fxData.get("igniteTime")
	if fxData.has("igniteDamage"):
		igniteDamage = fxData.get("igniteDamage")
	if fxData.has("curseTime"):
		curseDuration = fxData.get("curseTime")
	if fxData.has("curseDamageAmp"):
		curseDamageAmp = fxData.get("curseDamageAmp")
	if fxData.has("knockbackVelocity"):
		knockbackVelocity = fxData.get("knockbackVelocity")
	if fxData.has("stunTime"):
		stunTime = fxData.get("stunTime")
	if fxData.has("lingeringPoolTime"):
		lingeringPoolTime = fxData.get("lingeringPoolTime")
	if fxData.has("lingeringPoolRadius"):
		lingeringPoolRadius = fxData.get("lingeringPoolRadius")


	spawnExplosionArea()

# Can use this to check certain levels or special events
func setExplosionDetails(turret):
	match turret.turretID:
		
		Turret.TurretID.FIREWORK_TURRET:
			explosionType = ExplosionType.FIREWORK_TURRET
			if turret.level >= 2:
				igniteDamage = turret.burnDamage
				igniteTime = turret.burnTime
			return
		
		Turret.TurretID.FLAME_TURRET:
			explosionType = ExplosionType.FLAME_TURRET
			return
		
		Turret.TurretID.SEISMIC_TURRET:
			explosionType = ExplosionType.SEISMIC_TURRET
			return
		
		Turret.TurretID.VOODOO_TURRET:
			explosionType = ExplosionType.VOODOO_TURRET
			return
		
		Turret.TurretID.BUBBLE_TURRET:
			explosionType = ExplosionType.BUBBLE_TURRET
			return
		
		Turret.TurretID.MORTAR_TURRET:
			explosionType = ExplosionType.MORTAR_TURRET
			return

	explosionType = ExplosionType.NONE


func spawnExplosionArea() -> void:

	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	area.add_child(shape)
	area.set_collision_mask_value(3, true)
	area.set_collision_mask_value(1, true)
	area.collision_layer = 1

	var scene = get_tree().root.find_child("EnemyNodeHolder", true, false)

	scene.add_child(area)
	area.global_position = location


	if particle:
		var p = particle.instantiate() as CPUParticles2D
		scene.add_child(p)
		p.global_position = location
		

		var default_visual_radius = 48.0 
		var scaleFactor = radius / default_visual_radius
		
		
		#p.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
		
		p.scale_amount_min *= scaleFactor
		p.scale_amount_max *= scaleFactor
		
		p.initial_velocity_min = 0
		p.initial_velocity_max = 0

		#p.amount = 1
		p.one_shot = true
		p.emitting = true


	await get_tree().create_timer(.05).timeout

	# do the special posion or curse or whatever here
	if is_instance_valid(area):
		for body in area.get_overlapping_areas():
			#print("area: ", body.name, " | owner: ", body.owner, " | parent: ", body.get_parent())
			var enemy = body.get_parent()
			#print(enemy.enemyName)
			if enemy.is_in_group("Enemy"):
				EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.EXPLOSION, turretApplier, [], {}), enemy)
				if explosionType == ExplosionType.FLAME_TURRET:
					EffectManager.applyBurnEffect(enemy,turretApplier,igniteDamage,igniteTime)
				if explosionType == ExplosionType.FIREWORK_TURRET:
					if turretApplier.level >= 2:
						EffectManager.applyBurnEffect(enemy,turretApplier,igniteDamage,igniteTime)
				if explosionType == ExplosionType.VOODOO_TURRET:
					EffectManager.applyCurseEffect(enemy,turretApplier,curseDuration,curseDamageAmp)
				if explosionType == ExplosionType.BUBBLE_TURRET:
					enemy.applyKnockback(turretApplier.global_position,knockbackVelocity)
					EffectManager.applyStunEffect(enemy,turretApplier,stunTime)
			if enemy.is_in_group("Turret"):
				if turretApplier.turretID == Turret.TurretID.FLAME_TURRET:
					if turretApplier.level >= 3:
						if enemy != turretApplier:
							enemy.giveIgnitionRounds(turretApplier.ignitionRoundsTime,turretApplier.fireTime,turretApplier.fireDamage)

		await get_tree().create_timer(2.0).timeout
		if is_instance_valid(area):
			area.queue_free()



func spawnEnemyExplosion(enemy : Enemy, explosionRadius, explosionDamage) -> void:
	particle = explosionParticlesTexture.get(enemy.enemyID).get("scene")
	location = enemy.global_position

	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = explosionRadius
	shape.shape = circle
	area.add_child(shape)
	area.set_collision_mask_value(3, true)
	area.set_collision_mask_value(1, true)
	area.collision_layer = 1

	var scene = get_tree().root.find_child("EnemyNodeHolder", true, false)

	scene.add_child(area)
	area.global_position = location


	if particle:
		var p = particle.instantiate() as CPUParticles2D
		scene.add_child(p)
		p.global_position = location
		

		var default_visual_radius = 48.0 
		var scaleFactor = explosionRadius / default_visual_radius 

		
		
		#p.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
		
		p.scale_amount_min *= scaleFactor
		p.scale_amount_max *= scaleFactor
		
		p.initial_velocity_min = 0
		p.initial_velocity_max = 0

		#p.amount = 1
		p.one_shot = true
		p.emitting = true
	
	await get_tree().create_timer(.05).timeout
	
	if is_instance_valid(area):
		for body in area.get_overlapping_areas():
			if body.name == "SelectArea":
				var bod = body.get_parent()
				if bod.is_in_group("Turret"):
					EntityManager.turretTakeDamage(explosionDamage,bod,null,enemy)

		await get_tree().create_timer(2.0).timeout
		if is_instance_valid(area):
			area.queue_free()
