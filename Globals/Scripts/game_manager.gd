extends Node

var startingCash : int = 1000

var popupScene = load("res://Globals/Scene/Popup.tscn")

# This array will be in order, so 0 will be 1 and so on
var turretsNameArray = ["Arrow Turret","Mini Sentry Turret","Energizer Turret","Railgun Turret","Reaper Turret","Royal Turret",
"Flame Turret", "Firework Turret", "Spider Turret","Tesla Turret"]

var turretsPlaced = {}

var beacon

var summonDict = {}
var enemiesAlive = []

var hexagonMothershipCooldown = 10 # Every 10 waves one will appear

var enemyWaveCanAppear = {"Basic Square" : 1, "Speedy Triangle" : 5, "Shooty Diamond" : 10,"Hexagon Mothership" : 30}

var currentMoney = startingCash
var currentExperience = 0
var upgradeTokens = 10
var inGamePlayerLevel = 0

var inWave : bool = false
var currentWave : int = 4

var pandemonium = false

func addTurretToDict(turret):
	if turretsPlaced.has(turret.getName()):
		turretsPlaced[turret.getName()].append(turret)
	else:
		turretsPlaced[turret.getName()] = [turret]

func removeTurretFromGame(turret):
	var turretsList : Array = turretsPlaced.get(turret.getName())
	turretsList.erase(turret)
	turret.closeSelectMenu()

	if turret.energized:
		turret.energizerTurret.turretsEnergized -= 1
		turret.energizerTurret.turretsInRange.erase(turret)

	PlacementManager.occupied_cells.erase(PlacementManager.get_snapped_position(turret.position))

	for particle in turret.currentParticlesMap.values():
		particle.queue_free()

	turret.queue_free()

func removeEnemyFromGame(enemy : CharacterBody2D):
	if (enemiesAlive.find(enemy) >= 0):
		enemiesAlive.remove_at(enemiesAlive.find(enemy))

	EffectManager.clearEffects(enemy)

	enemy.queue_free()

func summonEnemy(enemyName : String):
	match enemyName:

		"Basic Square":
			var enemy = preload("res://Enemy Scenes/Basic Square.tscn")
			enemy = enemy.instantiate()
			enemiesAlive.append(enemy)
			enemy.position = generateRandomPosition()
			get_tree().current_scene.find_child("CanvasLayer").add_sibling(enemy)

		"Hexagon Mothership":
			var enemy = preload("res://Enemy Scenes/Hexagon Mothership.tscn")
			enemy = enemy.instantiate()
			enemiesAlive.append(enemy)
			enemy.position = Vector2(2100,540)
			get_tree().current_scene.find_child("CanvasLayer").add_sibling(enemy)

		"Speedy Triangle":
			var enemy = preload("res://Enemy Scenes/Speedy Triangle.tscn")
			enemy = enemy.instantiate()
			enemiesAlive.append(enemy)
			enemy.position = generateRandomPosition()
			get_tree().current_scene.find_child("CanvasLayer").add_sibling(enemy)

		"Shooty Diamond":
			var enemy = preload("res://Enemy Scenes/Shooty Diamond.tscn")
			enemy = enemy.instantiate()
			enemiesAlive.append(enemy)
			enemy.position = generateRandomPosition()
			get_tree().current_scene.find_child("CanvasLayer").add_sibling(enemy)

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


func summonEnemies():

	summonDict = {}

	var ln = log(currentWave / float(10)) / log(2.7182818)
	var summonTime = -.5 * ln + 2
	summonTime = round_to_dec(summonTime,2)

	if pandemonium:
		summonTime = .2

	var squareAmount = int(40 * log(currentWave) + 10)
	summonDict["Basic Square"] = squareAmount

	if currentWave >= enemyWaveCanAppear.get("Speedy Triangle"):
		var triangleAmount = int(40 * log(currentWave) + 10)
		summonDict["Speedy Triangle"] = triangleAmount

	if currentWave >= enemyWaveCanAppear.get("Shooty Diamond"):
		var triangleAmount = int(40 * log(currentWave) + 10)
		summonDict["Shooty Diamond"] = triangleAmount

	#summonEnemy("Hexagon Mothership")
	if currentWave >= enemyWaveCanAppear.get("Hexagon Mothership"):
		var rand = randi_range(1,10)
		if rand >= hexagonMothershipCooldown:
			summonDict["Hexagon Mothership"] = 1
			hexagonMothershipCooldown = 10
		else:
			hexagonMothershipCooldown -= 1


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

func getTurretByName(turretName):

	match turretName:

		"Arrow Turret":
			return load("res://Turret Scenes/Arrow Turret.tscn")
		"Mini Sentry Turret":
			return load("res://Turret Scenes/Mini Sentry Turret.tscn")
		"Energizer Turret":
			return load("res://Turret Scenes/Energizer Turret.tscn")
		"Railgun Turret":
			return load("res://Turret Scenes/Railgun Turret.tscn")
		"Reaper Turret":
			return load("res://Turret Scenes/Reaper Turret.tscn")
		"Royal Turret":
			return load("res://Turret Scenes/Royal Turret.tscn")
		"Flame Turret":
			return load("res://Turret Scenes/Flame Turret.tscn")
		"Firework Turret":
			return load("res://Turret Scenes/Firework Turret.tscn")
		"Spider Turret":
			return load("res://Turret Scenes/Spider Turret.tscn")
		"Tesla Turret":
			return load("res://Turret Scenes/Tesla Turret.tscn")

func getTurret(number):

	var turretName = turretsNameArray[number-1]

	match turretName:

		"Arrow Turret":
			return load("res://Turret Scenes/Arrow Turret.tscn")
		"Mini Sentry Turret":
			return load("res://Turret Scenes/Mini Sentry Turret.tscn")
		"Energizer Turret":
			return load("res://Turret Scenes/Energizer Turret.tscn")
		"Railgun Turret":
			return load("res://Turret Scenes/Railgun Turret.tscn")
		"Reaper Turret":
			return load("res://Turret Scenes/Reaper Turret.tscn")
		"Royal Turret":
			return load("res://Turret Scenes/Royal Turret.tscn")
		"Flame Turret":
			return load("res://Turret Scenes/Flame Turret.tscn")
		"Firework Turret":
			return load("res://Turret Scenes/Firework Turret.tscn")
		"Spider Turret":
			return load("res://Turret Scenes/Spider Turret.tscn")
		"Tesla Turret":
			return load("res://Turret Scenes/Tesla Turret.tscn")

func findTurretTexture(turretName):

	match turretName:

		"Arrow Turret":
			return load("res://Textures/Turrets/Arrow Turret/ArrowTurret.png")
		"Mini Sentry Turret":
			return load("res://Textures/Turrets/Mini Sentry Turret/MiniSentryTurret.png")
		"Energizer Turret":
			return load("res://Textures/Turrets/Energizer Turret/Energizer Turret.png")
		"Railgun Turret":
			return load("res://Textures/Turrets/Railgun Turret/RailgunTurret.png")
		"Reaper Turret":
			return load("res://Textures/Turrets/Reaper Turret/ReaperTurret.png")
		"Royal Turret":
			return load("res://Textures/Turrets/Royal Turret/RoyalTurret.png")
		"Flame Turret":
			return load("res://Textures/Turrets/Flame Turret/Flame Turret.png")
		"Firework Turret":
			return load("res://Textures/Turrets/Firework Turret/Firework Turret Bottom.png")
		"Spider Turret":
			return load("res://Textures/Turrets/Spider Turret/Spider Turret.png")
		"Tesla Turret":
			return load("res://Textures/Turrets/Tesla Turret/Tesla Turret.png")

func getBeaconPosition():
	return beacon.global_position

func calculateMoneyReward(enemyName):
	var baseMoney = 1 + (currentWave / 8)

	match enemyName:

		"Basic Square":
			var extraMoney = randi_range(0,1) # 50%
			if extraMoney > 0:
				if randi_range(1,4) == 4: # 25%
					extraMoney = extraMoney + randi_range(0,1) # 50%
			baseMoney = baseMoney + extraMoney

		"Speedy Triangle":
			var extraMoney = randi_range(0,2) # 50%
			if extraMoney > 0:
				if randi_range(1,4) == 4: # 25%
					extraMoney = extraMoney + randi_range(0,3) # 50%
			baseMoney = baseMoney + extraMoney

		"Shooty Diamond":
			var extraMoney = randi_range(0,4)
			if extraMoney > 3:
				if randi_range(1,4) >= 3:
					extraMoney = extraMoney + randi_range(0,5)
			baseMoney = baseMoney + extraMoney

	return baseMoney

func calculateExperienceReward(enemyName):

	match enemyName:

		"Basic Square":
			return floor((.3 * currentWave + 2))
		"Speedy Triangle":
			return floor((.5 * currentWave + 3))
		"Shooty Diamond":
			return floor((.7 * currentWave + 4))
		"Hexagon Mothership":
			return floor((1.3 * currentWave + 20))
		"Support Square":
			return floor((.4 * currentWave + 2.5))
		"Explosive Circle":
			return floor((.6 * currentWave + 7))

func closeAllMenus():
	for x in turretsPlaced.values():
		for z in x:
			if is_instance_valid(z):
				z.closeSelectMenu()


func startWave():

	currentWave += 1
	inWave = true

	summonEnemies()


func round_to_dec(num, digit): # SAME
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

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

	var nextLevelCost = ceil((inGamePlayerLevel+1) * 5.5 + 10)
	xpBar.max_value = nextLevelCost

func removeUpgradeToken():
	upgradeTokens -= 1
