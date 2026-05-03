extends Node

signal turretStorageChanged()

var cityHealth = 100

var previewMode : bool = false

var popupScene = preload("res://Globals/Scene/Popup.tscn")

var turretsPlaced = {}

# an enum list of IDs of the turrets you brought for the run
var turretsBrought = [Turret.TurretID.ARROW_TURRET,Turret.TurretID.SENTRY_TURRET,Turret.TurretID.ENERGIZER_TURRET,
Turret.TurretID.MINI_SENTRY_TURRET, Turret.TurretID.TESLA_TURRET, Turret.TurretID.FLAME_TURRET,
Turret.TurretID.ZOMBIE_TURRET, Turret.TurretID.SPIDER_TURRET,Turret.TurretID.VOODOO_TURRET,
Turret.TurretID.GOLD_MINE_TURRET]

var turretTempLevels = {}

# turretID and int of how many the player has
var turretStorage = {Turret.TurretID.ARROW_TURRET : 99, Turret.TurretID.MINI_SENTRY_TURRET : 99, Turret.TurretID.ENERGIZER_TURRET : 99,
Turret.TurretID.FIREWORK_TURRET : 99, Turret.TurretID.FLAME_TURRET : 99, Turret.TurretID.GOLD_MINE_TURRET : 99, Turret.TurretID.MEDIC_TURRET : 99,
Turret.TurretID.RAILGUN_TURRET : 99,Turret.TurretID.REAPER_TURRET : 99, Turret.TurretID.ROYAL_TURRET : 99, Turret.TurretID.SEISMIC_TURRET : 99,
Turret.TurretID.SENTRY_TURRET : 99, Turret.TurretID.SPIDER_TURRET : 99, Turret.TurretID.TESLA_TURRET : 99, Turret.TurretID.VOODOO_TURRET : 99,
Turret.TurretID.ZOMBIE_TURRET : 99}

func _ready() -> void:
	# This works for now but will crash the game later TODO FIX THIS LATER
	for item in turretsBrought:
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

func updateTurretLevels(turretID):
	if turretsPlaced.has(turretID):
		for turret : Turret in turretsPlaced.get(turretID):
			if is_instance_valid(turret):
				turret.applyUpgrade()
			else:
				turretsPlaced.get(turretID).erase(turret)

func getTurretAmount(turretID):
	if turretStorage.has(turretID):
		return turretStorage.get(turretID)
	else:
		return -1
