extends Turret

class_name BubbleTurret

var scanTurretsFirstTime : bool = false
var bubbleReady : bool = false

var turretsInRange = []

var bubbleTimer

var bubbleApplyTime : float
var bubbleTime : float
var bubbleHealth : float

var baseBubbleApplyTime : float
var baseBubbleTime : float
var baseBubbleHealth : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Future
	turretID = TurretID.BUBBLE_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	armor = TurretManager.getTurretStat(turretID,"armor")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"contructionTime")
	baseBubbleApplyTime = TurretManager.getTurretStat(turretID,"bubbleApplyTime")
	baseBubbleHealth = TurretManager.getTurretStat(turretID,"bubbleHealth")
	baseBubbleTime = TurretManager.getTurretStat(turretID,"bubbleTime")

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
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	baseHealth = maxHealth
	health = maxHealth

	bubbleTimer.wait_time = bubbleTime

	
	applyUpgrade()

	isPlaced = true

func _process(delta: float) -> void:
	if isPlaced and not scanTurretsFirstTime:
		scanTurretsFirstTime = true
		scanCurrentTurretsInRange()
	if bubbleReady and isPlaced and turretsInRange.size() > 0:
		bubbleReady = false
		for turret : Turret in turretsInRange:
			if is_instance_valid(turret) and turret != self:
				if not turret.hasBubble:
					applyBubble(turret)
					break
			else:
				turretsInRange.erase(turret)

func _on_range_area_body_entered(body: Node2D) -> void:
	if isPlaced:
		if body.is_in_group("Turret"):
			turretsInRange.append(body)
	if isPlaced:
		if bubbleTimer.is_stopped():
			bubbleTimer.start(bubbleApplyTime)


func _on_range_area_body_exited(body: Node2D) -> void:
	if isPlaced:
		turretsInRange.erase(body)

func applyBubble(turret : Turret):
	if is_instance_valid(turret):
		if not turret.hasBubble:
			turret.hasBubble = true
			turret.recieveBubble(bubbleHealth)
			topSprite.play("Ready")


func scanCurrentTurretsInRange():
	for x in rangeArea.get_overlapping_areas():
		if x.get_parent().is_in_group("Turret") and x.name.contains("SelectArea") and x.get_parent() != self:
			x = x.get_parent()
			turretsInRange.append(x)
			for turret in turretsInRange:
				turretsInRange = turretsInRange.filter(func(t): return is_instance_valid(t))
	bubbleTimer.start()

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	bubbleApplyTime = max(1,(bubbleApplyTime - scaleFactor))
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	bubbleHealth = (baseBubbleHealth + (baseBubbleHealth * scaleFactor * upgradeTier))


func _on_bubble_timer_timeout() -> void:
		scanCurrentTurretsInRange()
		if not bubbleReady:
			bubbleReady = true
