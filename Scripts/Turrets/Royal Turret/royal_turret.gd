extends Turret

class_name RoyalTurret

var summonTimer : Timer

var currentMinions : Array[Minion] = []

@onready var knightMinion = preload("res://Minion Scenes/Knight Minion.tscn")

var baseSummonTime : float

var maxKnights : int
@onready var baseKnightHealth : float  = TurretManager.getMinionStat(Minion.MinionID.KNIGHT,"health")
@onready var baseKnightDamage : float = TurretManager.getMinionStat(Minion.MinionID.KNIGHT,"damage")
@onready var baseKnightSpeed : float = TurretManager.getMinionStat(Minion.MinionID.KNIGHT,"speed")
@onready var baseKnightAttackTime : float = TurretManager.getMinionStat(Minion.MinionID.KNIGHT,"attackTime")

var currentKnightAmount : int = 0

var summonTime
var knightHealth
var knightDamage
var knightSpeed
var knightAttackTime

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		removeAllMinions()

func _ready() -> void:
	rarity = Rarity.SUPER_RARE
	type = Type.Midieval
	turretID = TurretID.ROYAL_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseHealth = maxHealth
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	baseSummonTime = TurretManager.getTurretStat(turretID,"summonTime")
	maxKnights =  TurretManager.getTurretStat(turretID,"maxKnights")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")

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
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	summonTime = baseSummonTime
	summonTimer.wait_time = baseSummonTime
	health = maxHealth
	knightDamage = baseKnightDamage
	knightHealth = baseKnightHealth
	knightSpeed = baseKnightSpeed
	knightAttackTime = knightAttackTime

	applyUpgrade()
	
	isPlaced = true

func _process(delta: float) -> void:
	if summonTimer.is_stopped() and currentKnightAmount < maxKnights:
		summonTimer.start()

func summonMinion():
	if currentKnightAmount < maxKnights:
		var knight = knightMinion.instantiate()
		knight.health = knightHealth
		knight.damage = knightDamage
		knight.speed = knightSpeed
		knight.attackTime = knightAttackTime
		knight.turretOwner = self

		knight.global_position = global_position
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

func removeMinion(minion : Minion):
	currentMinions.erase(minion)
	if minion.id == minion.MinionID.KNIGHT:
		currentKnightAmount -= 1

func _on_summon_timer_timeout() -> void:
	summonMinion()

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	summonTime = max(2,(baseSummonTime - (baseSummonTime * scaleFactor * upgradeTier)))
	summonTimer.wait_time = summonTime
	knightDamage = (baseKnightDamage + (baseKnightDamage * scaleFactor * upgradeTier))
	knightHealth = (baseKnightHealth + (baseKnightHealth * scaleFactor * upgradeTier))
	knightSpeed = (baseKnightSpeed + (baseKnightSpeed * scaleFactor * upgradeTier))
	knightAttackTime = (baseKnightAttackTime + (baseKnightAttackTime * scaleFactor * upgradeTier))
	for minion : Minion in currentMinions:
		if minion.id == Minion.MinionID.KNIGHT:
			minion.health = knightHealth
			minion.damage = knightDamage
			minion.speed = knightSpeed
			minion.attackTime = knightAttackTime
			minion.updateAttackTime()
	refreshUI(self)
