extends Node

var turretXpMap = {}

var turretsUpgradeTier = {}

var upgradeTierPercent = .02

func takeDamage(damage,turret,enemy,damageType):

	if turret == null and enemy.health - damage <= 0 and not enemy.isDead:
		onKill(null,enemy)
	else:
		if turret == null:
			enemy.health = enemy.health - damage

	if damageType.is_in_group("Turret Projectile"):
		var projectile = damageType
		if projectile.get("enterEffect") != null:
			projectile.playEnterEffect(enemy)
		if projectile.get("poison") != null:
			if projectile.poison:
				EffectManager.applyPoisonEffect(enemy,turret,projectile.poisonDamage,projectile.poisonTime)
		if projectile.get("execution") != null:
			if projectile.execution:
				onKill(turret,enemy)
				ParticleManager.playExecutionParticle(enemy)
		if projectile.get("curse") != null:
			if projectile.curse:
				EffectManager.applyCurseEffect(enemy,turret,projectile.curseTime)
		if enemy.effects.has("Curse"): # Curse effect amplifies damage by 25%
			damage += damage * enemy.curseDamageAmp
		if enemy.health - damage <= 0 and not enemy.isDead:
			onKill(turret,enemy)
			enemy.isDead = true
		else:
			enemy.health = enemy.health - damage
		if projectile.get("enemiesPierced") == null:
			projectile.queue_free()

	if enemy.effects.has("Curse"): # Curse effect amplifies damage by 25%
		damage += damage * enemy.curseDamageAmp

	if damageType.is_in_group("Minion"):
		if enemy.health - damage <= 0 and not enemy.isDead:
			onKill(turret,enemy)
			enemy.isDead = true
		else:
			enemy.health = enemy.health - damage

	if damageType.is_in_group("Effect"):
		if enemy.health - damage <= 0 and not enemy.isDead:
			onKill(turret,enemy)
			enemy.isDead = true
		else:
			enemy.health = enemy.health - damage

	if damageType.is_in_group("Turret Beam"):
		if enemy.health - damage <= 0 and not enemy.isDead:
			onKill(turret,enemy)
			enemy.isDead = true
		else:
			enemy.health = enemy.health - damage

	if damageType.is_in_group("Explosion"):
		if enemy.health - damage <= 0 and not enemy.isDead:
			onKill(turret,enemy)
			enemy.isDead = true
		else:
			enemy.health = enemy.health - damage

	if damageType.is_in_group("Turret"):
		if enemy.health - damage <= 0 and not enemy.isDead:
			onKill(turret,enemy)
			enemy.isDead = true
		else:
			enemy.health = enemy.health - damage

func entityTakeDamage(damage,entity):

	if entity.is_in_group("Turret"):
		var turret = entity
		if turret.armor > 0:
			damage -= damage * .3
			if turret.armor - damage <= 0:
				turret.armor = 0
			else:
				turret.armor -= damage
		else:
			if turret.health - damage <= 0:
				onDeath(turret)
				GameManager.removeTurretFromGame(turret)
			else:
				turret.health = turret.health - damage

	if entity.is_in_group("Minion"):
		var minion = entity
		if minion.armor > 0:
			damage -= damage * .3
			if minion.armor - damage <= 0:
				minion.armor = 0
			else:
				minion.armor -= damage
		else:
			if minion.health - damage <= 0:
				minion.turretOwner.removeMinion(minion)
			else:
				minion.health = minion.health - damage

func onDeath(turret):

	var turretName = turret.getName()

	match turretName:

		"Energizer Turret":
			for x in turret.turretsInRange:
				if is_instance_valid(x):
					if x.energized:
						x.currentParticlesMap.get("Energized").queue_free()
						x.currentParticlesMap.erase("Energized")
						turret.removeEnergizerBuffsToTurret(x)

		"Royal Turret":
			for x in turret.currentMinions:
				x.queue_free()


func onKill(turret,enemy):

	var enemyName = enemy.getName()

	var moneyEarned = GameManager.calculateMoneyReward(enemyName)
	var experienceEarned = GameManager.calculateExperienceReward(enemyName)

	GameManager.currentMoney += moneyEarned
	GameManager.currentExperience += experienceEarned

	if not DeveloperMode.inDevMode:
		get_tree().current_scene.find_child("XP Bar").value += experienceEarned

	SoundManager.playGenericKillSound()
	ParticleManager.playDeathParticle(enemy)

	GameManager.removeEnemyFromGame(enemy)

	if is_instance_valid(turret):
		if turret.is_in_group("Minion"):
			turret.turretOwner.addKill()
			turret.enemy = null
			addTurretXP(turret.turretOwner.getName(),experienceEarned)
		else:
			turret.addKill()
			addTurretXP(turret.getName(),experienceEarned)

func addTurretXP(turretName,xp):

	if (turretXpMap.has(turretName)):
		turretXpMap[turretName] = turretXpMap.get(turretName) + xp
	else:
		turretXpMap[turretName] = xp

func updateTurretUpgradeTier(turretName):

	if turretsUpgradeTier.has(turretName):
		turretsUpgradeTier[turretName] = turretsUpgradeTier.get(turretName) + 1
	else:
		turretsUpgradeTier[turretName] = 1

func applyUpgradeTier(turret):
	if turret.get("maxHealth") != null:
		turret.maxHealth += ceil(turret.maxHealth * upgradeTierPercent)
		turret.health = turret.maxHealth
	if turret.get("damage") != null:
		turret.baseDamage +=  ceil(turret.baseDamage * upgradeTierPercent)
		turret.damage = turret.baseDamage
	if turret.get("projectileSpeed") != null:
		turret.baseProjectileSpeed +=  ceil(turret.baseProjectileSpeed * upgradeTierPercent)
		turret.projectileSpeed = turret.baseProjectileSpeed
	if turret.get("attackRange") != null:
		turret.baseAttackRange +=  ceil(turret.baseAttackRange * upgradeTierPercent)
		turret.attackRange = turret.baseAttackRange
		turret.line2d = PlacementManager.draw_range_cirle(turret.line2d,turret.attackRange)
		turret.rangeCollisionShape.shape.radius = turret.attackRange
	if turret.get("reloadTime") != null:
		turret.baseReloadTime -=  round_to_dec(turret.baseReloadTime * upgradeTierPercent,2)
		turret.reloadTime = turret.baseReloadTime
		turret.reloadTimer.wait_time = turret.reloadTime
	if turret.get("explosionDamage") != null:
		turret.baseExplosionDamage +=  ceil(turret.baseExplosionDamage * upgradeTierPercent)
		turret.explosionDamage = turret.baseExplosionDamage
	if turret.get("explosionRadius") != null:
		turret.baseExplosionRadius +=  ceil(turret.baseExplosionRadius * upgradeTierPercent)
		turret.explosionRadius = turret.baseExplosionRadius
	if turret.get("fireDamage") != null:
		turret.baseFireDamage += 1
		turret.fireDamage = turret.baseFireDamage
	if turret.get("fireTime") != null:
		turret.baseFireTime += .5
		turret.fireTime = turret.baseFireTime
	if turret.get("pierce") != null:
		turret.basePierce += 1
		turret.pierce = turret.basePierce
	if turret.get("executionChance") != null:
		turret.executionChance += .5
	if turret.energized:
		if is_instance_valid(turret.energizerTurret):
			turret.energizerTurret.applyEnergizerBuffsToTurret(turret)

	specializedUpgrade(turret)

func upgradeTurret(turretNumber):

	if GameManager.turretsPlaced.size() > 0:
		var turretName = GameManager.turretsNameArray[turretNumber-1]

		if GameManager.turretsPlaced.has(turretName):
			var turretsList : Array = GameManager.turretsPlaced.get(turretName)
			for x in turretsList:
				x.upgrade.emit(x)

		updateTurretUpgradeTier(turretName)

func getUpgradeTier(turretName):
	if turretsUpgradeTier.has(turretName):
		return turretsUpgradeTier.get(turretName)
	else:
		return 0

func getClosestEnemyFromSprite(turret):
	var distance = 999999
	var enemy = null
	for x in turret.enemiesInRange:
		if (is_instance_valid(x)):
			if (turret.global_position.distance_to(x.global_position) < distance):
				distance = turret.global_position.distance_to(x.global_position)
				enemy = x
	if (enemy == null):
		print("No enemies around")
		return 0
	else:
		return enemy


func specializedUpgrade(turret):

	match turret.getName():

		"Flame Turret":
			turret.particleVelocity += 10
			turret.find_child("FlameArea").position.x += .4
			turret.find_child("FlameAreaShape2D").shape.height += .8
			turret.find_child("Flame Particle").process_material.set("initial_velocity",Vector2(turret.particleVelocity,turret.particleVelocity))

		"Royal Turret":
			turret.baseKnightHealth += ceil(turret.baseKnightHealth * .05)
			turret.knightHealth = turret.baseKnightHealth
			turret.baseKnightDamage += ceil(turret.baseKnightDamage * .05)
			turret.knightDamage = turret.baseKnightDamage
			turret.summonTime -=  round_to_dec(turret.summonTime * upgradeTierPercent,2)

func increaseEnemyStats(enemy):
	var currentWave = GameManager.currentWave

	var statIncrease = (currentWave / 10) * .05

	enemy.health += GameManager.round_to_dec(enemy.health * statIncrease,2)
	enemy.damage += GameManager.round_to_dec(enemy.damage * statIncrease,2)
	enemy.attackTime -= GameManager.round_to_dec(enemy.attackTime * statIncrease,2)
	enemy.speed += GameManager.round_to_dec(enemy.speed * statIncrease,2)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
