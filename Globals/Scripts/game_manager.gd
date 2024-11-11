extends Node

var startingCash : int = 1000

var popupScene = load("res://Globals/Scene/Popup.tscn")

var turretXpMap = {}

# This array will be in order, so 0 will be 1 and so on
var turretsNameArray = ["Arrow Turret","Mini Sentry Turret","Energizer Turret"]

var turretsUpgradeTier = {}

var turretsPlaced = {}

var beacon

var summonDict = {}
var enemiesAlive = []

var hexagonMothershipCooldown = 10 # Every 10 waves one will appear after round 30

var enemyWaveCanAppear = {"Basic Square" : 1, "Speedy Triangle" : 5, "Hexagon Mothership" : 30}

var currentMoney = startingCash
var currentExperience = 0
var upgradeTokens = 0
var inGamePlayerLevel = 0

var upgradeTierPercent = .02

var inWave : bool = false
var currentWave : int = 100

func addTurretToDict(turret):
	if turretsPlaced.has(turret.getName()):
		turretsPlaced[turret.getName()].append(turret)
	else:
		turretsPlaced[turret.getName()] = [turret]
		
func removeTurretFromGame(turret):
	var turretsList : Array = turretsPlaced.get(turret.getName())
	turretsList.erase(turret)
	turret.closeSelectMenu()
	
	PlacementManager.occupied_cells.erase(PlacementManager.get_snapped_position(turret.position))
	
	for particle in turret.currentParticlesMap.values():
		particle.queue_free()
	
	turret.queue_free()

func removeAliveEnemyFromList(enemy : CharacterBody2D):
	if (enemiesAlive.find(enemy) >= 0):
		enemiesAlive.remove_at(enemiesAlive.find(enemy))
		
		
func summonEnemy(enemyName : String):
	match enemyName:
		
		"Basic Square":
			var enemy = preload("res://Enemy Scenes/Basic Square.tscn")
			enemy = enemy.instantiate()
			enemiesAlive.append(enemy)
			enemy.position = generateRandomPosition()
			get_tree().root.get_node("/root/Game").find_child("CanvasLayer").add_sibling(enemy)
			
		"Hexagon Mothership":
			var enemy = preload("res://Enemy Scenes/Hexagon Mothership.tscn")
			enemy = enemy.instantiate()
			enemiesAlive.append(enemy)
			enemy.position = Vector2(2100,540)
			get_tree().root.get_node("/root/Game").find_child("CanvasLayer").add_sibling(enemy)

func generateRandomPosition():
	var side = randi_range(1,4)
	
	var randX
	var randY
	
	match side:
		
		1:
			randX = randf_range(0, 1920)
			randY = randf_range(0, 200)
		2:
			randX = randf_range(1920, 2120)
			randY = randf_range(0, 1080)
		3:
			randX = randf_range(0,1920)
			randY = randf_range(-200, 0)
		4:
			randX = randf_range(-200,0)
			randY = randf_range(0,1080)
		
		
	return Vector2(randX,randY)

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

func summonEnemies():
	
	summonDict = {}

	var ln = log(currentWave / float(10)) / log(2.7182818)
	var summonTime = -.5 * ln + 2
	summonTime = round_to_dec(summonTime,2)
	
	var squareAmount = int(40 * log(currentWave) + 10)
	summonDict["Basic Square"] = squareAmount
	
	#if enemyWaveCanAppear.get("Hexagon Mothership") >= currentWave chance to get one but will get one within 5 waves of appearing
	#summonEnemy("Hexagon Mothership")
	

	while true:
		if summonDict.size() > 0:
			var keys = summonDict.keys()
			var enemyName = keys[randi() % keys.size()]
			summonEnemy(enemyName)
			if (summonDict.get(enemyName) - 1 <= 0):
				summonDict.erase(enemyName)
			else:
				summonDict[enemyName] = summonDict.get(enemyName) - 1
			await get_tree().create_timer(summonTime).timeout
		else:
			break

	
func getEnemiesAlive():
	return enemiesAlive

func getTurret(number):
	
	var turretName = turretsNameArray[number-1]
	
	match turretName:
		
		
		"Arrow Turret":
			return load("res://Turret Scenes/Arrow Turret.tscn")
		"Mini Sentry Turret":
			return load("res://Turret Scenes/Mini Sentry Turret.tscn")
		"Energizer Turret":
			return load("res://Turret Scenes/Energizer Turret.tscn")

func getBeaconPosition():
	return beacon.global_position
	
func calculateMoneyReward(enemyName):
	var baseMoney = 1 + (currentWave / 3)
	
	match enemyName:
		
		"Basic Square":
			var extraMoney = randi_range(0,1) # 50%
			if extraMoney > 0:
				if randi_range(1,4) == 4: # 25%  
					extraMoney = extraMoney + randi_range(0,1) # 50%
			baseMoney = baseMoney + extraMoney
	
	return baseMoney

func calculateExperienceReward(enemyName):
	
	match enemyName:
		
		"Basic Square":
			return 2

func onKill(turret,enemy):
	
	var enemyName = enemy.getName()
	
	var moneyEarned = calculateMoneyReward(enemyName)
	var experienceEarned = calculateExperienceReward(enemyName)
	
	var popup = popupScene.instantiate()
	popup.global_position = enemy.global_position
	popup.killPopup(moneyEarned,experienceEarned)
	get_tree().root.get_node("/root/Game").find_child("CanvasLayer").add_child(popup)
	

	ParticleManager.playDeathParticle(enemy)

	currentMoney += moneyEarned
	currentExperience += experienceEarned
	
	get_tree().root.get_node("/root/Game").find_child("XP Bar").value += experienceEarned
	
	removeAliveEnemyFromList(enemy)
	
	if is_instance_valid(turret):
		turret.addKill()
		addTurretXP(turret.getName(),experienceEarned)

func addTurretXP(turretName,xp):
	
	if (turretXpMap.has(turretName)):
		turretXpMap[turretName] = turretXpMap.get(turretName) + xp
	else:
		turretXpMap[turretName] = xp

func closeAllMenus():
	for x in turretsPlaced.values():
		for z in x:
			if is_instance_valid(z):
				z.closeSelectMenu()

func updateTurretUpgradeTier(turretName):
	
	if turretsUpgradeTier.has(turretName):
		turretsUpgradeTier[turretName] = turretsUpgradeTier.get(turretName) + 1
	else:
		turretsUpgradeTier[turretName] = 1

func upgradeTurret(turretNumber):
	
	var turretName = turretsNameArray[turretNumber-1]
	
	var turretsList : Array = turretsPlaced.get(turretName)
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
		

func startWave():
	
	currentWave += 1
	inWave = true
	
	summonEnemies()


func round_to_dec(num, digit): # SAME
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func getUpgradeTierPercent():
	return upgradeTierPercent

func getCurrentMoney():
	return currentMoney
	
func subtractMoney(amount):
	currentMoney -= amount

func getCurrentXP():
	return currentExperience
	
func getUpgradeTokens():
	return upgradeTokens

func onInGameLevelUp(xpBar):
	upgradeTokens += 1
	inGamePlayerLevel += 1
	
	var nextLevelCost = round((inGamePlayerLevel+1) * 1.5 + 10)
	xpBar.max_value = nextLevelCost

func removeUpgradeToken():
	upgradeTokens -= 1
