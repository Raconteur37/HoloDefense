extends Node

# Check if they have "enter effects" plural

enum DamageType {
	TURRET, # The turret itself does the damage, no projectile or anything
	PROJECTILE, # The turret launched a projectile and that projectile is tied to the turret
	
}


var turretXpMap = {}

var turretsUpgradeTier = {}


func enemyTakeDamage(packet: DamagePacket, enemy: Enemy) -> void:
	if enemy.isDead:
		return

	var damage = packet.damage

	if enemy.effects.has(EffectClass.Effect.CURSE):
		damage += int(damage * enemy.curseDamageAmp)

	if packet.type == DamagePacket.Type.PROJECTILE:
		applyProjectileEffects(packet, enemy)
		
	if packet.type == DamagePacket.Type.EFFECT:
		
		# Other damage fx apply first, poison gets last priorirty bc of return
		if EffectClass.Effect.BURN in packet.effects:
			enemy.health = enemy.health - damage
		
		if EffectClass.Effect.POISON in packet.effects:
			enemy.health = max(1, enemy.health - damage)
		
		if enemy.health <= 0:
			killEnemy(packet.source, enemy)
		return

	enemy.health -= damage
	enemy.hurtParticle.emitting = true

	if enemy.health <= 0:
		killEnemy(packet.source, enemy)

# This will INCLUDE explosions cus why not
func applyProjectileEffects(packet: DamagePacket, enemy: Enemy) -> void:
	var turret = packet.source

	if EffectClass.Effect.POISON in packet.effects:
		EffectManager.applyPoisonEffect(
			enemy, turret,
			packet.effectData.get("poisonDamage", 0),
			packet.effectData.get("poisonTime", 0)
		)
	if EffectClass.Effect.CURSE in packet.effects:
		EffectManager.applyCurseEffect(
			enemy, turret,
			packet.effectData.get("curseTime", 0),
			packet.effectData.get("curseDamageAmp",0)
		)
	if EffectClass.Effect.EXECUTE in packet.effects:
		ParticleManager.playExecutionParticle(enemy)
		killEnemy(turret, enemy)
		
	if EffectClass.Effect.EXPLOSION in packet.effects:
		ExplosionManager.summonExplosion(turret,enemy,packet.effectData)

func killEnemy(source, enemy: Enemy) -> void:
	if enemy.isDead:
		return
	enemy.isDead = true
	onKill(source, enemy)


func turretTakeDamage(damage: float, turret : Turret, projectile) -> void:
	if projectile != null:
		if turret.hasBubble:
			turret.currentBubbleHealth -= damage
			bounceProjectile(projectile,turret)
			if turret.currentBubbleHealth <= 0:
				turret.removeBubble()
			return
		else:
			projectile.queue_free()

	damage = applyArmor(damage, turret)
	
	turret.health -= damage
	
	if turret.health <= 0:
		turret.health = 0
		GameManager.removeTurretFromGame(turret)
		PlacementManager.free_cell(turret.global_position)
		turret.queue_free()
		return

	turret.refreshUI(turret)


func applyArmor(damage: int, entity) -> int:
	if entity.armor <= 0:
		return damage

	var mitigated = int(damage * 0.7)  # always reduce damage by 30%

	var absorbed = min(entity.armor, mitigated)
	entity.armor -= absorbed
	entity.armor = max(entity.armor, 0)

	var remainder = mitigated - absorbed  # only what armor couldn't cover hits health
	return remainder

func onKill(turret,enemy):

	var enemyName = enemy.getName()

	if enemyName == "Dummy":
		enemy.queue_free()
		return

	SoundManager.playGenericKillSound()
	ParticleManager.playDeathParticle(enemy)

	#GameManager.removeEnemyFromGame(enemy)
	WaveManager.removeActiveEnemy(enemy)
	WaveManager.checkForEnemiesAlive()
	if enemy.type == Enemy.Type.BOSS:
		SoundManager.stopBossWaveSound()

	if is_instance_valid(turret) and turret != null:
		if turret.is_in_group("Minion"):
			turret.turretOwner.addKill()
			turret.enemy = null
			#addTurretXP(turret.turretOwner.getName(),experienceEarned)
		else:
			turret.addKill()
			#addTurretXP(turret.getName(),experienceEarned)
	
	enemy.queue_free()
	

func healTurret(turret,amountHealed):
	if turret.health + amountHealed > turret.maxHealth:
		turret.health = turret.maxHealth
	else:
		turret.health += amountHealed
	ParticleManager.playHealParticle(turret)
	if is_instance_valid(turret.menu):
		turret.menu.healthUpdate()

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

# Handle upgrade alone so this will be deleted

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
		return 0
	else:
		return enemy


func increaseEnemyStats(enemy):
	var currentWave = GameManager.currentWave

	var statIncrease = (currentWave / 10) * .05

	enemy.health += GameManager.round_to_dec(enemy.health * statIncrease,2)
	enemy.damage += GameManager.round_to_dec(enemy.damage * statIncrease,2)
	enemy.attackTime -= GameManager.round_to_dec(enemy.attackTime * statIncrease,2)
	enemy.speed += GameManager.round_to_dec(enemy.speed * statIncrease,2)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


func bounceProjectile(projectile: Node, turret):
	# direction away from turret center
	var bounceDir = (projectile.global_position - turret.global_position).normalized()
	var bounceTarget = projectile.global_position + bounceDir * 40.0

	var tween = create_tween()
	tween.set_parallel(true)

	# fly outward
	tween.tween_property(projectile, "global_position", bounceTarget, 0.18) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# squish on impact
	tween.tween_property(projectile, "scale", Vector2(1.4, 0.6), 0.07) \
		.set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(projectile, "scale", Vector2(1.0, 1.0), 0.1) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

	# fade out
	tween.tween_property(projectile, "modulate:a", 0.0, 0.18) \
		.set_ease(Tween.EASE_IN)

	# remove after animation
	tween.chain().tween_callback(projectile.queue_free)
