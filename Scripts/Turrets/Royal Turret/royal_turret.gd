extends Turret

class_name RoyalTurret

var summonTimer : Timer

var currentMinions : Array[Minion] = []

@onready var knightMinion = preload("res://Minion Scenes/Knight Minion.tscn")
@onready var archerMinion = preload("res://Minion Scenes/Archer Minion.tscn")
@onready var bardMinion = preload("res://Minion Scenes/Bard Minion.tscn")

var baseSummonTime : float

var maxKnights : int
@onready var baseKnightHealth : float  = TurretManager.getMinionStat(Minion.MinionID.KNIGHT,"health")
@onready var baseKnightDamage : float = TurretManager.getMinionStat(Minion.MinionID.KNIGHT,"damage")
@onready var baseKnightSpeed : float = TurretManager.getMinionStat(Minion.MinionID.KNIGHT,"speed")
@onready var baseKnightAttackTime : float = TurretManager.getMinionStat(Minion.MinionID.KNIGHT,"attackTime")

var maxArchers : int
@onready var baseArcherHealth : float  = TurretManager.getMinionStat(Minion.MinionID.ARCHER,"health")
@onready var baseArcherDamage : float = TurretManager.getMinionStat(Minion.MinionID.ARCHER,"damage")
@onready var baseArcherSpeed : float = TurretManager.getMinionStat(Minion.MinionID.ARCHER,"speed")
@onready var baseArcherAttackTime : float = TurretManager.getMinionStat(Minion.MinionID.ARCHER,"attackTime")
@onready var baseArcherRange : float = TurretManager.getMinionStat(Minion.MinionID.ARCHER,"attackRange")
@onready var baseArcherProjectileSpeed : float = TurretManager.getMinionStat(Minion.MinionID.ARCHER,"projectileSpeed")

var maxBards : int
@onready var baseBardHealth : float  = TurretManager.getMinionStat(Minion.MinionID.BARD,"health")
@onready var baseBardSpeed : float = TurretManager.getMinionStat(Minion.MinionID.BARD,"speed")
@onready var baseBardAttackTime : float = TurretManager.getMinionStat(Minion.MinionID.BARD,"attackTime")
@onready var baseBardHeal : float = TurretManager.getMinionStat(Minion.MinionID.BARD,"healAmount")


var currentKnightAmount : int = 0
var currentArcherAmount : int = 0
var currentBardAmount : int = 0

var archerSummonChance : int 
var bardSummonChance : float

var summonTime

var knightHealth
var knightDamage
var knightSpeed
var knightAttackTime

var archerHealth
var archerDamage
var archerSpeed
var archerRange
var archerAttackTime
var archerProjectileSpeed

var bardHealth
var bardSpeed
var bardAttackTime
var bardHeal

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		removeAllMinions()

func _ready() -> void:
	rarity = Rarity.SUPER_RARE
	turretID = TurretID.ROYAL_TURRET
	type = TurretManager.getTurretTypeEnum(turretID)
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseHealth = maxHealth
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	baseSummonTime = TurretManager.getTurretStat(turretID,"summonTime")
	maxKnights =  TurretManager.getTurretStat(turretID,"maxKnights")
	maxArchers = TurretManager.getTurretStat(turretID,"maxArchers")
	maxBards = TurretManager.getTurretStat(turretID,"maxBards")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	archerSummonChance = TurretManager.getTurretStat(turretID,"archerSummonChance")
	bardSummonChance = TurretManager.getTurretStat(turretID,"bardSummonChance")

	level = XpManager.getCurrentLevel(turretID)
	upgradeTier = 0

	summonTimer = $SummonTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	bottomSprite = $TurretBottom
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	summonTime = baseSummonTime
	summonTimer.wait_time = baseSummonTime
	health = maxHealth
	
	knightDamage = baseKnightDamage
	knightHealth = baseKnightHealth
	knightSpeed = baseKnightSpeed
	knightAttackTime = baseKnightAttackTime

	archerDamage = baseArcherDamage
	archerHealth = baseArcherHealth
	archerSpeed = baseArcherSpeed
	archerRange = baseArcherRange
	archerAttackTime = baseArcherAttackTime
	archerProjectileSpeed = baseArcherProjectileSpeed

	bardHealth = baseBardHealth
	bardSpeed = baseBardSpeed
	bardAttackTime = baseBardAttackTime
	bardHeal = baseBardHeal

	applyUpgrade()
	
	isPlaced = true

func _process(delta: float) -> void:
	if summonTimer.is_stopped() and currentKnightAmount < maxKnights:
		summonTimer.start()

func summonMinion():
	if currentKnightAmount < maxKnights:
		var knight = knightMinion.instantiate()
		knight.maxHealth = knightHealth
		knight.health = knightHealth
		knight.damage = knightDamage
		knight.speed = knightSpeed
		knight.attackTime = knightAttackTime
		knight.turretOwner = self

		knight.global_position = to_local(global_position)
		knight.velocity = Vector2(randi_range(-1,1),randi_range(-1,1)).normalized() * 500

		currentMinions.append(knight)

		currentKnightAmount += 1

		get_parent().add_child(knight)
	if level >= 2:
		if randf_range(0,100) <= archerSummonChance:
			if currentArcherAmount < maxArchers:
				var archer : Minion = archerMinion.instantiate()
				archer.maxHealth = archerHealth
				archer.health = archerHealth
				archer.damage = archerDamage
				archer.attackTime = archerAttackTime
				archer.attackRange = archerRange
				archer.speed = archerSpeed
				archer.projectileSpeed = archerProjectileSpeed
				archer.turretOwner = self
				
				archer.global_position = global_position
				archer.velocity = Vector2(randi_range(-1,1),randi_range(-1,1)).normalized() * 500

				currentMinions.append(archer)

				currentArcherAmount += 1
				
				get_parent().add_child(archer)
	if level >= 3:
		if randf_range(0,100) <= bardSummonChance:
			if currentBardAmount < maxBards:
				var bard : Minion = bardMinion.instantiate()
				bard.maxHealth = bardHealth
				bard.health = bardHealth
				bard.speed = bardSpeed
				bard.healAmount = bardHeal
				bard.attackTime = bardAttackTime
				bard.turretOwner = self
				
				bard.global_position = global_position
				bard.velocity = Vector2(randi_range(-1,1),randi_range(-1,1)).normalized() * 500

				currentMinions.append(bard)

				currentBardAmount += 1
				
				get_parent().add_child(bard)

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

func removeMinion(minion : Minion):
	currentMinions.erase(minion)
	if minion.id == minion.MinionID.KNIGHT:
		currentKnightAmount -= 1

func _on_summon_timer_timeout() -> void:
	summonMinion()

func applyUpgrade(): #TODO FIX THIS ATTACK TIME
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	summonTime = max(2,(baseSummonTime - (baseSummonTime * scaleFactor * upgradeTier)))
	summonTimer.wait_time = summonTime
	knightDamage = (baseKnightDamage + (baseKnightDamage * scaleFactor * upgradeTier))
	knightHealth = (baseKnightHealth + (baseKnightHealth * scaleFactor * upgradeTier))
	knightSpeed = (baseKnightSpeed + (baseKnightSpeed * scaleFactor * upgradeTier))
	#knightAttackTime -= (baseKnightAttackTime + (baseKnightAttackTime * scaleFactor * upgradeTier))
	archerDamage = (baseArcherDamage + (baseArcherDamage * scaleFactor * upgradeTier))
	archerHealth = (baseArcherHealth + (baseArcherHealth * scaleFactor * upgradeTier))
	archerSpeed = (baseArcherHealth + (baseArcherHealth * scaleFactor * upgradeTier))
	#archerAttackTime -= (baseArcherAttackTime + (baseArcherAttackTime * scaleFactor * upgradeTier))
	archerProjectileSpeed = (baseArcherProjectileSpeed + (baseArcherProjectileSpeed * scaleFactor * upgradeTier))
	archerRange = (baseArcherRange + (baseArcherRange * scaleFactor * upgradeTier))
	bardHealth = (baseBardHealth + (baseBardHealth * scaleFactor * upgradeTier))
	bardSpeed = (baseBardSpeed + (baseBardSpeed * scaleFactor * upgradeTier))
	bardHeal = (baseBardHeal + (baseBardHeal * scaleFactor * upgradeTier))
	#bardAttackTime -= (baseBardAttackTime + (baseBardAttackTime * scaleFactor * upgradeTier))
	for minion : Minion in currentMinions:
		if minion.id == Minion.MinionID.KNIGHT:
			minion.maxHealth = knightHealth
			minion.health = knightHealth
			minion.damage = knightDamage
			minion.speed = knightSpeed
			minion.attackTime = knightAttackTime
			minion.updateAttackTime()
		if minion.id == Minion.MinionID.ARCHER:
			minion.maxHealth = archerHealth
			minion.health = archerHealth
			minion.damage = archerDamage
			minion.speed = archerSpeed
			minion.attackTime = archerAttackTime
			minion.projectileSpeed = archerProjectileSpeed
			minion.range = archerRange
			minion.updateAttackTime()
		if minion.id == Minion.MinionID.BARD:
			minion.maxHealth = bardHealth
			minion.health = bardHealth
			minion.speed = bardSpeed
			minion.attackTime = bardAttackTime
			minion.healAmount = bardHeal
			minion.updateAttackTime()
	refreshUI(self)
