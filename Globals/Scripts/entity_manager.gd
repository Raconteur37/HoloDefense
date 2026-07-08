extends Node

enum DamageType {
	TURRET,     # The turret itself does the damage, no projectile or anything
	PROJECTILE, # The turret launched a projectile and that projectile is tied to the turret
}

var turretXpMap = {}
var turretsUpgradeTier = {}


func enemyTakeDamage(packet: DamagePacket, enemy: Enemy) -> void:
	if enemy.isDead:
		return
		
	if is_instance_valid(packet.source):
		var turret = packet.source as Turret
		var damage = packet.damage

		if enemy.effects.has(EffectClass.Effect.CURSE):
			damage += int(damage * (enemy.curseDamageAmp * 0.01))

		# Handle specific packet types
		match packet.type:
			DamagePacket.Type.TURRET:
				if is_instance_valid(turret):
					StatManager.addStat(turret.turretID, "damage_dealt", damage)
					if turret.turretID == Turret.TurretID.TESLA_TURRET and turret.level >= 2:
						EffectManager.applyStunEffect(enemy, turret, turret.stunTime)

			DamagePacket.Type.EXPLOSION:
				if is_instance_valid(turret):
					StatManager.addStat(turret.turretID, "damage_dealt", damage)

			DamagePacket.Type.PROJECTILE:
				applyProjectileEffects(packet, enemy)
				if is_instance_valid(turret):
					StatManager.addStat(turret.turretID, "damage_dealt", damage)
					
			DamagePacket.Type.EFFECT:
				if EffectClass.Effect.BURN in packet.effects:
					enemy.health -= damage
				elif EffectClass.Effect.POISON in packet.effects:
					enemy.health = max(1, enemy.health - damage)

				if is_instance_valid(turret) and (EffectClass.Effect.BURN in packet.effects or EffectClass.Effect.POISON in packet.effects):
					StatManager.addStat(turret.turretID, "damage_dealt", damage)
				
				if enemy.health <= 0:
					killEnemy(turret, enemy)
				return # Effects handle their own death checks, so we return early

		# Apply standard damage
		enemy.health -= damage

		if enemy.health <= 0:
			killEnemy(turret, enemy)
		else:
			enemy.hurtParticle.emitting = true
			if is_instance_valid(enemy):
				var tween = create_tween()
				enemy.sprite.material.set_shader_parameter("flash_modifier", 1.0)
				tween.tween_property(enemy.sprite.material, "shader_parameter/flash_modifier", 0.0, 0.1)


# This will INCLUDE explosions
func applyProjectileEffects(packet: DamagePacket, enemy: Enemy) -> void:
	var turret = packet.source
	
	if not is_instance_valid(turret):
		return
		
	if EffectClass.Effect.WEB in packet.effects:
		var webScene = load("res://TurretAddons/Web.tscn")
		var web = webScene.instantiate()
		turret.add_child(web)
		web.setupWeb(turret, packet.effectData.get("webDuration"), enemy.global_position)

	if EffectClass.Effect.BURN in packet.effects:
		EffectManager.applyBurnEffect(enemy, turret, packet.effectData.get("burnDamage", 0), packet.effectData.get("burnTime", 0))
		StatManager.addStat(turret.turretID, "enemiesIgnited", 1)
		XpManager.addXp(turret.turretID)
		
	if EffectClass.Effect.POISON in packet.effects:
		EffectManager.applyPoisonEffect(enemy, turret, packet.effectData.get("poisonDamage", 0), packet.effectData.get("poisonTime", 0))
		StatManager.addStat(turret.turretID, "enemiesPoisoned", 1)
		XpManager.addXp(turret.turretID)
		
	if EffectClass.Effect.CURSE in packet.effects:
		EffectManager.applyCurseEffect(enemy, turret, packet.effectData.get("curseTime", 0), packet.effectData.get("curseDamageAmp", 0))
		StatManager.addStat(turret.turretID, "enemiesCursed", 1)
		XpManager.addXp(turret.turretID)
		
	if EffectClass.Effect.EXECUTE in packet.effects:
		ParticleManager.playExecutionParticle(enemy)
		killEnemy(turret, enemy)
		StatManager.addStat(turret.turretID, "enemiesExecuted", 1)
		XpManager.addXp(turret.turretID)
		
	if EffectClass.Effect.EXPLOSION in packet.effects:
		ExplosionManager.summonExplosion(turret, enemy.global_position, packet.effectData)


func killEnemy(source: Node, enemy: Enemy) -> void:
	if enemy.isDead:
		return
	enemy.isDead = true
	onKill(source, enemy)


func turretTakeDamage(damage: float, entity: Node, projectile: Node, damager) -> void:
	if damager is Enemy:
		if damager.effects.has(EffectClass.Effect.CURSE):
			if is_instance_valid(damager.effects.get(EffectClass.Effect.CURSE).turretApplier):
				if damager.effects.get(EffectClass.Effect.CURSE).turretApplier.level >= 3 and damager.effects.get(EffectClass.Effect.CURSE).turretApplier.turretID == Turret.TurretID.VOODOO_TURRET:
					var damageReduction = damager.effects.get(EffectClass.Effect.CURSE).turretApplier.damageReduction * 0.01
					damageReduction = damage * damageReduction
					damage = damage - damageReduction
					print(damage)
	if entity is Turret:
		var turret = entity
		if projectile != null:
			if turret.hasBubble:
				turret.currentBubbleHealth -= damage
				bounceProjectile(projectile, turret)
				if turret.currentBubbleHealth <= 0:
					turret.removeBubble(true)
				return
			else:
				projectile.queue_free()

		var takenDamage = applyArmor(damage, turret)
		turret.health -= takenDamage
		StatManager.addStat(turret.turretID, "damage_taken", takenDamage)
		
		if turret.health <= 0:
			turret.health = 0
			GameManager.removeTurretFromGame(turret)
			PlacementManager.free_cell(turret.global_position)
			turret.death()
			return

		turret.refreshUI(turret)
		
		match turret.turretID:
			Turret.TurretID.MINI_SENTRY_TURRET:
				if turret.level >= 3:
					turret.stopRepairEvent()
			Turret.TurretID.RAILGUN_TURRET:
				if turret.level >= 2:
					turret.attackedReloadCooldownReduction()
					
	elif entity is Minion:
		var minion = entity
		minion.health -= damage
		
		minion.flash_damage()
		
		if minion.health <= 0:
			minion.health = 0
			minion.death()



func applyArmor(damage: int, entity: Node) -> int:
	if entity.armor <= 0:
		return damage

	var mitigated = int(damage * 0.7)  # always reduce damage by 30%
	var absorbed = min(entity.armor, mitigated)
	
	entity.armor -= absorbed
	entity.armor = max(entity.armor, 0)

	var remainder = mitigated - absorbed  # only what armor couldn't cover hits health
	return remainder


func onKill(source: Node, enemy: Enemy) -> void:
	var enemyName = enemy.getName()
	var tier = enemy.tier
	
	match tier:
		1:
			StatManager.tierOneEnemiesKilled += 1
			if enemy.enemyID == Enemy.EnemyID.BASIC_SQUARE:
				StatManager.basicSquaresKilled += 1
		2: 
			StatManager.tierTwoEnemiesKilled += 1
			if enemy.enemyID == Enemy.EnemyID.SPEEDY_TRIANGLE:
				StatManager.speedyTrianglesKilled += 1
			if enemy.enemyID == Enemy.EnemyID.TANKY_RECTANGLE:
				StatManager.tankyRectanglesKilled += 1
		3: 
			if enemy.enemyID == Enemy.EnemyID.SHOOTY_DIAMOND:
				StatManager.shootyDiamondsKilled += 1
			StatManager.tierThreeEnemiesKilled += 1

	if enemyName == "Dummy":
		enemy.queue_free()
		return

	SoundManager.playGenericKillSound()
	ParticleManager.playDeathParticle(enemy)
	WaveManager.removeActiveEnemy(enemy)
	WaveManager.checkForEnemiesAlive()
	StatManager.enemiesKilled += 1
	
	if enemy.type == Enemy.Type.BOSS:
		SoundManager.stopBossWaveSound()
		StatManager.bossesKilled += 1
		if enemy.enemyID == Enemy.EnemyID.HEXAGON_MOTHERSHIP:
			StatManager.hexagonMothershipsKilled += 1

	var turret = source as Turret
	if is_instance_valid(turret):
		if turret.is_in_group("Minion"):
			StatManager.addStat(turret.turretOwner.turretID, "kills", 1)
			turret.enemy = null
		else:
			match turret.turretID:
				Turret.TurretID.FIREWORK_TURRET:
					if turret.level >= 3:
						turret.tryRefundShot()
				Turret.TurretID.MINI_SENTRY_TURRET:
					if turret.level >= 2:
						turret.startSpeedEvent()
				Turret.TurretID.RAILGUN_TURRET:
					if turret.level >= 3:
						turret.killReloadCooldownReduction()
				Turret.TurretID.FLAME_TURRET:
					if turret.level >= 2 and EffectClass.Effect.BURN in enemy.effects:
						var fxData = {
							"explosionRadius": turret.explosionRange,
							"igniteTime": turret.fireTime,
							"igniteDamage": turret.fireDamage
						}
						ExplosionManager.summonExplosion(turret, enemy.global_position, fxData)
				Turret.TurretID.SEISMIC_TURRET:
					if turret.level >= 3:
						var fxData = {
							"explosionRadius": turret.chainRange,
							"explosionDamage": turret.damage
						}
						ExplosionManager.summonExplosion(turret, enemy.global_position, fxData)
				Turret.TurretID.VOODOO_TURRET:
					if enemy.effects.has(EffectClass.Effect.CURSE):
						if turret.level >= 2:
							var fxData = {
								"explosionRadius": turret.explosionRadius,
								"curseTime": turret.curseDuration,
								"curseDamageAmp": turret.curseDamageAmp
							}
							ExplosionManager.summonExplosion(turret, enemy.global_position, fxData)
				Turret.TurretID.ZOMBIE_TURRET:
					if turret.level >= 2 and enemy.effects.has(EffectClass.Effect.ZOMBIFY):
						var gravestone = preload("res://TurretAddons/Gravestone.tscn")
						gravestone = gravestone.instantiate()
						turret.add_child(gravestone)
						gravestone.build(turret,turret.gravestoneRange,turret.gravestoneTime)
						gravestone.global_position = enemy.global_position
			if turret.goldenBuff:
				if is_instance_valid(turret.turretProviders["golden"]):
					var rand = randf_range(0,100)
					if rand <= turret.turretProviders["golden"].killChance:
						CityManager.currentMoney += turret.turretProviders["golden"].extraGold
						print("made " + str(turret.turretProviders["golden"].extraGold))
			

			XpManager.addXp(turret.turretID)
			StatManager.addStat(turret.turretID, "kills", 1)
	
	for body in enemy.hitBoxArea.get_overlapping_areas():
		var entities = body.get_parent()
		if entities.is_in_group("Gravestone"):
			var gravestone = entities
			EffectManager.applyZombifyEffect(enemy,gravestone.turretApplier,gravestone.turretApplier.turnTime)
			StatManager.addStat(gravestone.turretApplier.turretID,"enemies_zombified",1)
			XpManager.addXp(gravestone.turretApplier.turretID)
			return
	enemy.queue_free()


func healTurret(healer: Turret, turret: Turret, amountHealed: float) -> void:
	var actualHeal = amountHealed
	
	if turret.health + amountHealed > turret.maxHealth:
		actualHeal = turret.maxHealth - turret.health
		turret.health = turret.maxHealth
	else:
		turret.health += amountHealed
		
	StatManager.addStat(healer.turretID, "healthHealed", actualHeal)
	XpManager.addXp(turret.turretID)
	ParticleManager.playHealParticle(turret)
	
	if is_instance_valid(turret.menu):
		turret.menu.healthUpdate()


func updateTurretUpgradeTier(turretName: String) -> void:
	if turretsUpgradeTier.has(turretName):
		turretsUpgradeTier[turretName] = turretsUpgradeTier.get(turretName) + 1
	else:
		turretsUpgradeTier[turretName] = 1


func getClosestEnemyFromSprite(turret) -> Enemy:
	var closestDistance = 999999.0
	var targetEnemy = null
	
	for enemy in turret.enemiesInRange:
		if is_instance_valid(enemy):
			var currentDistance = turret.global_position.distance_to(enemy.global_position)
			if currentDistance < closestDistance:
				closestDistance = currentDistance
				targetEnemy = enemy
				
	return targetEnemy


func increaseEnemyStats(enemy: Enemy) -> void:
	var currentWave = GameManager.currentWave
	var statIncrease = (currentWave / 10.0) * 0.05

	enemy.health += roundToDec(enemy.health * statIncrease, 2)
	enemy.damage += roundToDec(enemy.damage * statIncrease, 2)
	enemy.attackTime -= roundToDec(enemy.attackTime * statIncrease, 2)
	enemy.speed += roundToDec(enemy.speed * statIncrease, 2)


func roundToDec(num: float, digit: int) -> float:
	var multiplier = pow(10.0, digit)
	return round(num * multiplier) / multiplier


func bounceProjectile(projectile: Node, turret: Turret) -> void:
	var bounceDir = (projectile.global_position - turret.global_position).normalized()
	var bounceTarget = projectile.global_position + bounceDir * 40.0

	var tween = create_tween()
	tween.set_parallel(true)

	# Fly outward
	tween.tween_property(projectile, "global_position", bounceTarget, 0.18) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# Squish on impact
	tween.tween_property(projectile, "scale", Vector2(1.4, 0.6), 0.07) \
		.set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(projectile, "scale", Vector2(1.0, 1.0), 0.1) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

	# Fade out
	tween.tween_property(projectile, "modulate:a", 0.0, 0.18) \
		.set_ease(Tween.EASE_IN)

	# Remove after animation
	tween.chain().tween_callback(projectile.queue_free)
