extends Turret
class_name BubbleTurret
var turretsInRange = []
var bubbleTimer
var bubbleApplyTime: float
var bubbleTime: float
var bubbleHealth: float
var baseBubbleApplyTime: float
var baseBubbleTime: float
var baseBubbleHealth: float
var bubbleReady : bool = false
var baseMaxBubbles : int
var maxBubbles : int
var currentBubblesGiven : int = 0

var baseShieldProvided : int
var shieldProvided : int

var baseKnockbackRange : float
var knockbackRange : float

var baseKnockbackVelocity : float
var knockbackVelocity : float

var baseStunTime : float
var stunTime : float

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		onDeath()

func onDeath():
	for turret in turretsInRange:
		if is_instance_valid(turret) and turret.hasBubble:
			turret.removeBubble(false)

func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Future
	turretID = TurretID.BUBBLE_TURRET
	turretName = TurretManager.getTurretStat(turretID, "name")
	price = TurretManager.getTurretStat(turretID, "price")
	maxHealth = TurretManager.getTurretStat(turretID, "health")
	baseAttackRange = TurretManager.getTurretStat(turretID, "range")
	armor = TurretManager.getTurretStat(turretID, "armor")
	scaleFactor = TurretManager.getTurretStat(turretID, "scaleFactor")
	baseBuildTime = TurretManager.getTurretStat(turretID, "contructionTime")
	baseBubbleApplyTime = TurretManager.getTurretStat(turretID, "bubbleApplyTime")
	baseBubbleHealth = TurretManager.getTurretStat(turretID, "bubbleHealth")
	baseBubbleTime = TurretManager.getTurretStat(turretID, "bubbleTime")
	baseMaxBubbles = TurretManager.getTurretStat(turretID, "maxBubbleTurrets")
	baseShieldProvided = TurretManager.getTurretStat(turretID, "shieldProvided")
	baseKnockbackRange = TurretManager.getTurretStat(turretID, "knockbackRadius")
	baseKnockbackVelocity = TurretManager.getTurretStat(turretID, "knockbackVelocity")
	baseStunTime = TurretManager.getTurretStat(turretID, "stunTime")
	bubbleHealth = baseBubbleHealth
	bubbleApplyTime = baseBubbleApplyTime
	bubbleTime = baseBubbleTime
	maxBubbles = baseMaxBubbles
	level = 3#XpManager.getCurrentLevel(turretID)
	upgradeTier = 0
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	bottomSprite = $TurretBottom
	bodyCollisionShape = $CollisionShape2D
	bubbleTimer = $BubbleTimer
	rangeArea = $RangeArea
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d, attackRange)
	rangeCollisionShape.shape.radius = attackRange
	baseHealth = maxHealth
	health = maxHealth
	bubbleTimer.wait_time = bubbleApplyTime
	shieldProvided = baseShieldProvided
	stunTime = baseStunTime
	knockbackRange = baseKnockbackRange
	knockbackVelocity = baseKnockbackVelocity
	applyUpgrade()
	isPlaced = true
	call_deferred("scanCurrentTurretsInRange")

func _process(delta: float) -> void:
	if turretsInRange.is_empty() or not isPlaced:
		return
	if currentBubblesGiven >= maxBubbles:
		return
	for turret: Turret in turretsInRange:
		if is_instance_valid(turret) and turret != self and not turret.hasBubble and bubbleReady:
			applyBubble(turret)
			bubbleReady = false
			break

func _on_range_area_body_entered(body: Node2D) -> void:
	if not isPlaced or not body.is_in_group("Turret"):
		return
	if not turretsInRange.has(body):
		turretsInRange.append(body)
	if bubbleTimer.is_stopped() and currentBubblesGiven < maxBubbles:
		bubbleTimer.start(bubbleApplyTime)

func _on_range_area_body_exited(body: Node2D) -> void:
	if isPlaced:
		turretsInRange.erase(body)

func applyBubble(turret: Turret):
	if not is_instance_valid(turret) or turret.hasBubble:
		return
	if currentBubblesGiven >= maxBubbles:
		return
	turret.hasBubble = true
	turret.recieveBubble(bubbleHealth,self)
	currentBubblesGiven += 1
	StatManager.addStat(turretID,"bubbles_provided",1)
	XpManager.addXp(turretID)
	topSprite.play("Ready")
	if currentBubblesGiven >= maxBubbles:
		bubbleTimer.stop()
	if level >= 2:
		turret.armor += shieldProvided

func scanCurrentTurretsInRange():
	turretsInRange.clear()
	for area in rangeArea.get_overlapping_areas():
		var parent = area.get_parent()
		if parent.is_in_group("Turret") and area.name.contains("SelectArea") and parent != self:
			turretsInRange.append(parent)
	turretsInRange = turretsInRange.filter(func(t): return is_instance_valid(t))
	if currentBubblesGiven < maxBubbles:
		bubbleTimer.start()

func _clean_turrets_array():
	turretsInRange = turretsInRange.filter(func(t): return is_instance_valid(t))

func _on_bubble_timer_timeout() -> void:
	_clean_turrets_array()
	if currentBubblesGiven >= maxBubbles:
		return
	bubbleReady = true
	if bubbleTimer.is_stopped():
		bubbleTimer.start(bubbleApplyTime)

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	if upgradeTier == 0:
		return
	attackRange = baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier)
	bubbleApplyTime = max(1, baseBubbleApplyTime - scaleFactor * upgradeTier)
	maxHealth = baseHealth + (baseHealth * scaleFactor * upgradeTier)
	health = maxHealth
	bubbleHealth = baseBubbleHealth + (baseBubbleHealth * scaleFactor * upgradeTier)
	shieldProvided = round(baseShieldProvided + (baseShieldProvided * scaleFactor * upgradeTier))
	knockbackRange = baseKnockbackRange + (baseKnockbackRange * scaleFactor * upgradeTier)
	knockbackVelocity = baseKnockbackVelocity + (baseKnockbackVelocity * scaleFactor * upgradeTier)
	stunTime = baseStunTime + (baseStunTime * scaleFactor * upgradeTier)
	maxBubbles += 1

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()
