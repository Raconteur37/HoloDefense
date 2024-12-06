extends Node

var popupScene = load("res://Globals/Scene/Popup.tscn")

var turretXpMap = {}

var turretsUpgradeTier = {}

func takeDamage(damage,turret,enemy,projectile):
	
	var popup = popupScene.instantiate()
	popup.global_position = enemy.global_position
	popup.damagePopup(damage)
	get_tree().root.current_scene.find_child("CanvasLayer").add_child(popup)
	
	if projectile.get("enterEffect") != null:
		projectile.playEnterEffect(self)
	if projectile.get("enemiesPierced") == null:
		pass
	if damage > 99999:
		ParticleManager.playExecutionParticle(enemy)
	if enemy.health - damage <= 0 and not enemy.isDead:
		GameManager.onKill(turret,enemy)
		enemy.isDead = true
	else:
		enemy.health = enemy.health - damage
		
		
func turretTakeDamage(damage,turret):
	if turret.armor > 0:
		damage -= damage * .3
		if turret.armor - damage <= 0:
			turret.armor = 0
		else:
			turret.armor -= damage
	else:
		if turret.health - damage <= 0:
			GameManager.removeTurretFromGame(self)
		else:
			turret.health = turret.health - damage

func onKill(turret,enemy):
	
	var enemyName = enemy.getName()
	
	var moneyEarned = GameManager.calculateMoneyReward(enemyName)
	var experienceEarned = GameManager.calculateExperienceReward(enemyName)
	
	GameManager.currentMoney += moneyEarned
	GameManager.currentExperience += experienceEarned
	
	get_tree().root.current_scene.find_child("XP Bar").value += experienceEarned
	
	var popup = popupScene.instantiate()
	popup.global_position = enemy.global_position
	popup.killPopup(moneyEarned,experienceEarned)
	get_tree().root.current_scene.find_child("CanvasLayer").add_child(popup)
	
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

func upgradeTurret(turretNumber):
	
	if GameManager.turretsPlaced.size() > 0:
		var turretName = GameManager.turretsNameArray[turretNumber-1]
		
		if GameManager.turretsPlaced.has(turretName):
			var turretsList : Array = GameManager.turretsPlaced.get(turretName)
			for x in turretsList:
				x.applyUpgradeTier()
				if x.energized:
					x.energizerTurret.applyEnergizerBuffsToTurret(x)
				
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
