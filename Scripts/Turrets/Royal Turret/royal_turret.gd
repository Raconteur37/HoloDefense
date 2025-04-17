extends Turret

class_name RoyalTurret

var summonTimer

var currentMinions = []

@onready var knightMinion = preload("res://Minion Scenes/Knight Minion.tscn")

@export var baseSummonTime : float = 5

@export var maxKnights : int = 3
@export var baseKnightHealth : float  = 30
@export var baseKnightDamage : float = 10

var currentKnightAmount : int = 0

var summonTime
var knightHealth
var knightDamage

func _ready() -> void:
	rarity = Rarity.SUPER_RARE
	type = Type.Midieval
	turretName = "Royal Turret"
	price = 80
	maxHealth = 20
	baseAttackRange = 200
	upgradeTier = 0
	armor = 50
	level = 1
	baseBuildTime = 25

	summonTimer = $SummonTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	attackRange = baseAttackRange
	line2d = PlacementManager.draw_range_cirle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	summonTime = baseSummonTime
	summonTimer.wait_time = baseSummonTime
	health = maxHealth
	knightDamage = baseKnightDamage
	knightHealth = baseKnightHealth

	hit.connect(EntityManager.entityTakeDamage)
	upgrade.connect(EntityManager.applyUpgradeTier)

	upgradeTier = EntityManager.getUpgradeTier(turretName)

	for x in range(upgradeTier):
		upgrade.emit(self)

	if DeveloperMode.inDevMode and not PlacementManager.inGame:
		isPlaced = true
		GameManager.addTurretToDict(self)
		health = 9999

func _process(delta: float) -> void:
	if isPlaced and not isCollisionReady:
		bodyCollisionShape.disabled = false
		isCollisionReady = true
		summonTimer.start()
	if not beaconBuffActive:
		BeaconManager.applyBeaconBuffs()

func summonMinion():
	if currentKnightAmount < maxKnights:
		var knight = knightMinion.instantiate()
		knight.health = knightHealth
		knight.damage = knightDamage
		knight.turretOwner = self

		knight.position = position
		knight.velocity = Vector2(randi_range(-1,1),randi_range(-1,1)).normalized() * 500

		currentMinions.append(knight)

		currentKnightAmount += 1

		get_parent().add_child(knight)

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true

func isEnemyTargeted(enemy):
	for x in currentMinions:
		if x.enemy == enemy:
			return true

func removeMinion(minion):
	currentMinions.erase(minion)
	if minion.getName().find("Knight") > -1:
		currentKnightAmount -= 1
	minion.queue_free()

func _on_summon_timer_timeout() -> void:
	summonMinion()
