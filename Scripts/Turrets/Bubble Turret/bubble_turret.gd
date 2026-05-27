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
	bubbleHealth = baseBubbleHealth
	bubbleApplyTime = baseBubbleApplyTime
	bubbleTime = baseBubbleTime

	level = 1
	upgradeTier = 0

	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	bodyCollisionShape = $CollisionShape2D
	bubbleTimer = $BubbleTimer
	rangeArea = $RangeArea
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d, attackRange)
	rangeCollisionShape.shape.radius = attackRange
	baseHealth = maxHealth
	health = maxHealth
	bubbleTimer.wait_time = bubbleApplyTime

	applyUpgrade()
	isPlaced = true
	call_deferred("scanCurrentTurretsInRange")

func _process(delta: float) -> void:
	if turretsInRange.is_empty() or not isPlaced:
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
	if bubbleTimer.is_stopped():
		bubbleTimer.start(bubbleApplyTime)

func _on_range_area_body_exited(body: Node2D) -> void:
	if isPlaced:
		turretsInRange.erase(body)

func applyBubble(turret: Turret):
	if not is_instance_valid(turret) or turret.hasBubble:
		return
	turret.hasBubble = true
	turret.recieveBubble(bubbleHealth)
	topSprite.play("Ready")

func scanCurrentTurretsInRange():
	turretsInRange.clear()
	for area in rangeArea.get_overlapping_areas():
		var parent = area.get_parent()
		if parent.is_in_group("Turret") and area.name.contains("SelectArea") and parent != self:
			turretsInRange.append(parent)
	turretsInRange = turretsInRange.filter(func(t): return is_instance_valid(t))
	bubbleTimer.start()

func _clean_turrets_array():
	turretsInRange = turretsInRange.filter(func(t): return is_instance_valid(t))

func _on_bubble_timer_timeout() -> void:
	_clean_turrets_array()
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

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()
