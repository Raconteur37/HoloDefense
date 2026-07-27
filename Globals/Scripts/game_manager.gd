extends Node

signal turretStorageChanged()

var cityHealth = 100

var previewMode : bool = false
var VSmode : bool = false

var popupScene = preload("res://Globals/Scene/Popup.tscn")

var turretsPlaced = {}

var difficultySave = 1

var turretTargetToggle: bool = false
var turretTargetting

# an enum list of IDs of the turrets you brought for the run
var turretsBrought = [Turret.TurretID.ARROW_TURRET,Turret.TurretID.MINI_SENTRY_TURRET,Turret.TurretID.RAILGUN_TURRET,Turret.TurretID.SEISMIC_TURRET,
Turret.TurretID.SENTRY_TURRET,Turret.TurretID.FLAME_TURRET,Turret.TurretID.ENERGIZER_TURRET,
Turret.TurretID.GOLD_MINE_TURRET,Turret.TurretID.TESLA_TURRET,Turret.TurretID.ZOMBIE_TURRET,
Turret.TurretID.BUBBLE_TURRET,Turret.TurretID.BOOMERANG_TURRET,Turret.TurretID.MORTAR_TURRET]

var turretTempLevels = {}

# turretID and int of how many the player has
#var turretStorage = {Turret.TurretID.RAILGUN_TURRET : 99,Turret.TurretID.VOODOO_TURRET : 99,Turret.TurretID.ZOMBIE_TURRET : 99,Turret.TurretID.BOOMERANG_TURRET : 99, Turret.TurretID.BUBBLE_TURRET : 99}
#Turret.TurretID.ENERGIZER_TURRET : 99}

var turretStorage = {}

var fabricator

func _ready() -> void:
	randomize()
	if turretTempLevels.size() < 1:
		for item in TurretManager.ALL_TURRETS:
			turretTempLevels[item] = 0
	if DeveloperMode.inDevMode:
		turretStorage = {Turret.TurretID.MEDIC_TURRET : 99,Turret.TurretID.ENERGIZER_TURRET : 99,Turret.TurretID.ZOMBIE_TURRET : 99,Turret.TurretID.BOOMERANG_TURRET : 99, Turret.TurretID.BUBBLE_TURRET : 99,
		Turret.TurretID.SEISMIC_TURRET : 99, Turret.TurretID.ROYAL_TURRET : 99, Turret.TurretID.FLAME_TURRET : 99,
		Turret.TurretID.SENTRY_TURRET : 99, Turret.TurretID.ARROW_TURRET : 99,Turret.TurretID.FIREWORK_TURRET : 99,
		Turret.TurretID.REAPER_TURRET : 99, Turret.TurretID.MORTAR_TURRET : 99, Turret.TurretID.TESLA_TURRET : 99}
		for item in turretStorage.keys():
			turretTempLevels[item] = 0

func addTurretToDict(turret : Turret):
	if turretsPlaced.has(turret.turretID):
		turretsPlaced[turret.turretID].append(turret)
	else:
		turretsPlaced[turret.turretID] = [turret]

func removeTurretFromGame(turret):
	if is_instance_valid(turret):
		if turretsPlaced.has(turret.turretID):
			turretsPlaced[turret.turretID].erase(turret)
	for id in turretsPlaced.keys():
			turretsPlaced[id] = turretsPlaced[id].filter(func(t): return is_instance_valid(t))

func round_to_dec(num, digit): # SAME
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func addTurretToStorage(turretID,amount):
	if turretStorage.has(turretID):
		turretStorage[turretID] = turretStorage.get(turretID) + amount
	else:
		turretStorage[turretID] = amount
	turretStorageChanged.emit()

func removeTurretFromStorage(turretID,amount):
	if turretStorage.has(turretID):
		turretStorage[turretID] = turretStorage.get(turretID) - amount
		if turretStorage.get(turretID) <= 0:
			turretStorage.erase(turretID)
		turretStorageChanged.emit()

func getTurretTempLevel(turretID):
	if turretTempLevels.has(turretID):
		return turretTempLevels.get(turretID)
	else:
		return 0

func updateTurretLevels(turretID):
	if turretsPlaced.has(turretID):
		for turret : Turret in turretsPlaced.get(turretID):
			if is_instance_valid(turret):
				turret.applyUpgrade()
				if turret.energized:
					if turret.get("damage") != null:
						turret.damage += ceil(turret.turretProviders["energized"].energizerDamageBuff * turret.baseDamage)
					if turret.get("projectileSpeed") != null:
						turret.projectileSpeed += ceil(turret.turretProviders["energized"].energizerProjctileSpeedBuff * turret.baseProjectileSpeed)
					if turret.get("attackRange") != null:
						turret.attackRange += ceil(turret.turretProviders["energized"].energizerAttackRangeBuff * turret.baseAttackRange)
						turret.line2d = TurretManager.draw_range_circle(turret.line2d, turret.attackRange)
						turret.rangeCollisionShape.shape.radius = turret.attackRange
					if turret.get("reloadTime") != null:
						turret.reloadTime -= round_to_dec(turret.turretProviders["energized"].energizerReloadTimeBuff * turret.baseReloadTime, 2)
						if turret.get("reloadTimer") != null:
							turret.reloadTimer.wait_time = turret.reloadTime
			else:
				turretsPlaced.get(turretID).erase(turret)

func updatePriority(turretID, enemyID, type):
	if turretsPlaced.has(turretID):
		var turret_array = turretsPlaced.get(turretID)
		
		# Loop backwards from the end of the array to 0
		for i in range(turret_array.size() - 1, -1, -1):
			var turret = turret_array[i]
			
			if is_instance_valid(turret):
				turret.priorityTarget = enemyID
				turret.priorityType = type
			else:
				# Safely remove the invalid turret without breaking the loop
				turret_array.remove_at(i)

func getTurretAmount(turretID):
	if turretStorage.has(turretID):
		return turretStorage.get(turretID)
	else:
		return -1

func getRandomTurret() -> CharacterBody2D:
	var all_turrets = []
	
	for turret_list in turretsPlaced.values():
		all_turrets.append_array(turret_list)
	
	if all_turrets.is_empty():
		return null
		
	var random_turret = all_turrets.pick_random()
	return random_turret

func reset():
	StatManager.commitRunToLifetimeStats()
	WaveManager.reset()
	CityManager.reset()
	SoundManager.reset()
	StatManager.reset()
	
	Engine.time_scale = 1
	
	cityHealth = 100
	previewMode = false
	VSmode = false
	turretsPlaced.clear()
	turretStorage.clear()
	turretTempLevels.clear()
	
	# Reinitialise temp levels for brought turrets
	for item in turretsBrought:
		turretTempLevels[item] = 0
	
	# Free any turret instances still in the scene
	for id in turretsPlaced.keys():
		for turret in turretsPlaced[id]:
			if is_instance_valid(turret):
				turret.queue_free()
	turretsPlaced.clear()
	turretsBrought.clear()
	
	turretStorageChanged.emit()

func updatePriorities():
	if fabricator != null:
		fabricator.updateTurretPriorities()

func format_number(num: int) -> String:
	if num >= 1_000_000_000:
		return "%.1fB" % (num / 1_000_000_000.0)
	elif num >= 1_000_000:
		return "%.1fM" % (num / 1_000_000.0)
	elif num >= 1_000:
		return "%.1fK" % (num / 1_000.0)
	return str(num)
