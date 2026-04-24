extends CharacterBody2D

class_name Turret

var isPlaced : bool = false
var selected : bool = false
var shotReady : bool = true
var isCollisionReady : bool = false

enum TurretID {
	NONE,
	ARROW_TURRET,
	SENTRY_TURRET,
	ENERGIZER_TURRET,
	FIREWORK_TURRET,
	FLAME_TURRET,
	GOLD_MINE_TURRET,
	GRAVITY_TURRET,
	MEDIC_TURRET,
	MINI_SENTRY_TURRET,
	RAILGUN_TURRET,
	REAPER_TURRET,
	ROYAL_TURRET,
	SEISMIC_TURRET,
	SPIDER_TURRET,
	VOODOO_TURRET,
	TESLA_TURRET,
	ZOMBIE_TURRET
}

signal hit(damage,turret)
signal upgrade(turret)

var enemiesInRange = []

var effects : Dictionary = {}

var currentParticlesMap = {}

var line2d
var reloadTimer
var rangeCollisionShape
var rangeIndicator
var topSprite : AnimatedSprite2D
var selectArea
var bodyCollisionShape

#stats
var kills : int = 0

var projectile

var menu

enum Rarity { COMMON, RARE, SUPER_RARE, LEGENDARY, UNSEEN}
var rarity : Rarity
enum Type {Midieval, Modern, Future, Elemental, Armory, Dark, Biological, Magic, Idk}
var type : Type
var turretID : TurretID

var scaleFactor : float

var turretName : String = "None"
@export var price : int = 20
@export var maxHealth : float = 20
@export var baseDamage : float = 20
@export var baseProjectileSpeed : float = 400
@export var baseAttackRange : float = 200
@export var baseReloadTime : float = 3.5
@export var upgradeTier : int = 0
@export var armor : int = 0
@export var level : int = 1
@export var baseBuildTime : float = 5

var damage
var projectileSpeed
var attackRange
var reloadTime
var buildTime

var health : float

var energized : bool = false
var beaconBuffActive : bool = false

var energizerTurret : Turret = null

func addKill():
	kills += 1

func showRange():
	line2d.show()

func hideRange():
	line2d.hide()

func getName():
	return turretName

func getCost():
	return price

func showUI(turretInstance):
	rangeIndicator.show()
	# display UI if we can
	var bottomUI = get_tree().current_scene
	if bottomUI != null:
		if bottomUI.has_node("TowerDefenseCanvas"):
			bottomUI = bottomUI.find_child("TowerDefenseCanvas")
		bottomUI.refreshTurretUI(turretInstance)

func hideUI():
	rangeIndicator.hide()
	var bottomUI = get_tree().current_scene
	if bottomUI != null:
		if bottomUI.has_node("TowerDefenseCanvas"):
			bottomUI = bottomUI.find_child("TowerDefenseCanvas")
		bottomUI.removeTurretUI()
