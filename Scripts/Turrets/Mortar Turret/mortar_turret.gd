extends Turret

class_name MortarTurret

@onready var innerRangeLine = $InvalidRangeArea/RangeIndicator
@onready var particle = $TurretTop/CPUParticles2D

var innerRange: float
var explosionDamage: float
var explosionRadius: float
var poolIgniteDamage: float
var poolIgniteTime: float
var poolRadius: float
var shotDelay: float
var extraShots: int
var travelTime : float
var poolTime : float

var baseExplosionDamage: float
var baseExplosionRadius: float
var basePoolIgniteDamage: float
var basePoolIgniteTime: float
var basePoolRadius: float
var basePoolTime: float

func _ready() -> void:

	projectile = preload("res://Projectile Scenes/mortar shell.tscn")

	rarity = Rarity.COMMON
	turretID = TurretID.MORTAR_TURRET

	type = TurretManager.getTurretTypeEnum(turretID)
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	baseHealth = TurretManager.getTurretStat(turretID,"health")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	innerRange = TurretManager.getTurretStat(turretID, "innerRange")
	baseExplosionDamage = TurretManager.getTurretStat(turretID, "explosionDamage")
	baseExplosionRadius = TurretManager.getTurretStat(turretID, "explosionRadius")
	basePoolIgniteDamage = TurretManager.getTurretStat(turretID, "poolIgniteDamage")
	basePoolIgniteTime = TurretManager.getTurretStat(turretID, "poolIgniteTime")
	basePoolRadius = TurretManager.getTurretStat(turretID, "poolRadius")
	shotDelay = TurretManager.getTurretStat(turretID, "shotDelay")
	extraShots = TurretManager.getTurretStat(turretID, "extraShots")
	travelTime = TurretManager.getTurretStat(turretID, "travelTime")
	basePoolTime = TurretManager.getTurretStat(turretID, "poolLifetime")

	upgradeTier = 0
	level = XpManager.getCurrentLevel(turretID)

	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	bottomSprite = $TurretBottom
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	selectAreaCollisionShape = $SelectArea/CollisionShape2D
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	innerRangeLine = TurretManager.draw_range_circle($InvalidRangeArea/RangeIndicator,innerRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	maxHealth = baseHealth
	health = maxHealth
	
	explosionDamage = baseExplosionDamage 
	explosionRadius = baseExplosionRadius 
	poolIgniteDamage = basePoolIgniteDamage 
	poolIgniteTime = basePoolIgniteTime
	poolTime = basePoolTime
	poolRadius = basePoolRadius


	hideRange()

	applyUpgrade()

	isPlaced = true

func attack():
	if shotReady and enemiesInRange.size() > 0 and isPlaced:
		
		var enemy = filterEnemy()

		if is_instance_valid(enemy) and isPlaced:
			
			var enemyPos = enemy.global_position
			
			shotReady = false
			
			particle.emitting = true

			var proj = projectile.instantiate()
			
			get_parent().add_child(proj)
			
			proj.travel_time = travelTime
			proj.fire(position, enemyPos)
			proj.shooter = self
			
			# Flip the sprite horizontally based on which side the enemy is on
			if enemyPos.x < global_position.x:
				topSprite.flip_h = true  # Enemy is to the left
			else:
				topSprite.flip_h = false # Enemy is to the right
			
			if level >= 3:
				for i in range(extraShots):
					await get_tree().create_timer(shotDelay).timeout
					particle.emitting = true
					
					proj = projectile.instantiate()
					
					get_parent().add_child(proj)
					
					proj.travel_time = travelTime
					proj.fire(position, enemyPos)
					proj.shooter = self
					
					if enemyPos.x < global_position.x:
						topSprite.flip_h = true  # Enemy is to the left
					else:
						topSprite.flip_h = false # Enemy is to the right
					

			reloadTimer.start()
			reloadAnimation()



func reloadAnimation():
	var frameTime = reloadTime / 14.0
	var tween = create_tween()
	
	tween.tween_callback(func(): topSprite.frame = 1).set_delay(frameTime * 0)
	tween.tween_callback(func(): topSprite.frame = 2).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 3).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 4).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 5).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 6).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 7).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 8).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 9).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 10).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 11).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 12).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 13).set_delay(frameTime)
	tween.tween_callback(func(): topSprite.frame = 0).set_delay(frameTime)

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true

func _on_select_area_mouse_entered() -> void:
	super()
	innerRangeLine.show()

func _on_select_area_mouse_exited() -> void:
	super()
	innerRangeLine.hide()


func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	explosionDamage = (baseExplosionDamage + (baseExplosionDamage * scaleFactor * upgradeTier))
	explosionRadius = (baseExplosionRadius + (baseExplosionRadius * scaleFactor * upgradeTier))
	poolIgniteDamage = (basePoolIgniteDamage + (basePoolIgniteDamage * scaleFactor * upgradeTier))
	poolIgniteTime = (basePoolIgniteTime + (basePoolIgniteTime * scaleFactor * upgradeTier))
	poolTime = (basePoolTime + (basePoolTime * scaleFactor * upgradeTier))
	poolRadius = (basePoolRadius + (basePoolRadius * scaleFactor * upgradeTier))
	refreshUI(self)


func _on_invalid_range_area_body_entered(body: Node2D) -> void:
	if enemiesInRange.has(body):
		enemiesInRange.erase(body)


func _on_invalid_range_area_body_exited(body: Node2D) -> void:
	if not enemiesInRange.has(body):
		enemiesInRange.append(body)
