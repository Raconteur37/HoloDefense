extends Turret

class_name RoyalTurret

var summonTimer : Timer

var currentMinions = []

@onready var knightMinion = preload("res://Minion Scenes/Knight Minion.tscn")

@export var baseSummonTime : float

@export var maxKnights : int
@export var baseKnightHealth : float  = 30
@export var baseKnightDamage : float = 10

var currentKnightAmount : int = 0

var summonTime
var knightHealth
var knightDamage

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		removeAllMinions()

func _ready() -> void:
	rarity = Rarity.SUPER_RARE
	type = Type.Midieval

	turretName = TurretManager.getTurretStat("royal_turret","name")
	price = TurretManager.getTurretStat("royal_turret","price")
	maxHealth = TurretManager.getTurretStat("royal_turret","health")
	baseAttackRange = TurretManager.getTurretStat("royal_turret","range")
	armor = TurretManager.getTurretStat("royal_turret","armor")
	baseBuildTime = TurretManager.getTurretStat("royal_turret","constructionTime")
	baseSummonTime = TurretManager.getTurretStat("royal_turret","summonTime")
	maxKnights =  TurretManager.getTurretStat("royal_turret","maxKnights")

	level = 1
	upgradeTier = 0

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
	if GameManager.previewMode:
		var dummy = load("res://Enemy Scenes/Dummy.tscn")
		dummy = dummy.instantiate()
		dummy.global_position = to_local(global_position)
		dummy.global_position.x += 100
		add_child(dummy)

func _process(delta: float) -> void:
	if summonTimer.is_stopped() and currentKnightAmount < maxKnights:
		summonTimer.start()

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

func removeAllMinions():
	for minion in currentMinions:
		if is_instance_valid(minion):
			minion.queue_free()

func removeMinion(minion):
	currentMinions.erase(minion)
	if minion.getName().find("Knight") > -1:
		currentKnightAmount -= 1
	minion.queue_free()

func _on_summon_timer_timeout() -> void:
	summonMinion()
