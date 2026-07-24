extends Turret

class_name ZombieTurret

@export var turnChance : float
@export var turnTime : float

var baseTurnChance
var baseTurnTime

var attackTimer : Timer

var baseGravestoneRange : float
var gravestoneRange : float

var baseGravestoneTime : float
var gravestoneTime : float

func _ready() -> void:

	projectile = preload("res://Particle Scenes/Turrets/Tesla Turret/Electricity Shoot.tscn")


	rarity = Rarity.UNSEEN
	type = Type.Dark
	turretID = TurretID.ZOMBIE_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseHealth = maxHealth
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	baseTurnChance = TurretManager.getTurretStat(turretID,"turnChance")
	baseTurnTime = TurretManager.getTurretStat(turretID,"turnTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	baseGravestoneRange = TurretManager.getTurretStat(turretID,"gravestoneRange")
	baseGravestoneTime = TurretManager.getTurretStat(turretID,"gravestoneTime")
	

	turnChance = baseTurnChance
	turnTime = baseTurnTime

	upgradeTier = 0
	level = XpManager.getCurrentLevel(turretID)

	line2d = $RangeArea/RangeIndicator
	attackTimer = $AttackTimer
	attackTimer.wait_time = turnTime
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	bottomSprite = $TurretBottom
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	damage = baseDamage
	health = maxHealth
	gravestoneRange = baseGravestoneRange
	gravestoneTime = baseGravestoneTime

	isPlaced = true
	
	applyUpgrade()

func attack():
	if shotReady and enemiesInRange.size() > 0 and isPlaced and attackTimer.is_stopped():
		attackTimer.start()

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true

func _on_attack_timer_timeout() -> void:
	if enemiesInRange.size() > 0:
		for enemy in enemiesInRange:
			var shockParticle = projectile.instantiate()
			shockParticle.modulate = Color(0.0, 0.458, 0.0, 1.0)
			shockParticle.global_position = to_local(global_position)

			# Set the positions
			var start_position = Vector2(0,0)
			var end_position = to_local(enemy.global_position)
			var points = [start_position,end_position]

			shockParticle.points = points

			# Add to the scene
			get_parent().add_child(shockParticle)
			if not enemy.isZombie:
				if randi_range(0,100) <= turnChance:
					EffectManager.applyZombifyEffect(enemy,self,turnTime)
					StatManager.addStat(turretID,"enemies_zombified",1)
					XpManager.addXp(turretID)
		attackTimer.start()


func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	turnTime = (baseTurnTime + (baseTurnTime * scaleFactor * upgradeTier))
	attackTimer.wait_time = turnTime
	turnChance = (baseTurnChance + (baseTurnChance * scaleFactor * upgradeTier))
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	gravestoneRange = (baseGravestoneRange + (baseGravestoneRange * scaleFactor * upgradeTier))
	gravestoneTime = (baseGravestoneTime + (baseGravestoneTime * scaleFactor * upgradeTier))
	health = maxHealth
	refreshUI(self)
