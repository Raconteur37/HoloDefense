extends Turret

class_name SentryTurret

var shootTimer : Timer
var particle

@export var maxBullets : int # Bullets shot before needing to reload
@export var shotTime : float # The interval of which each bullet will be shot

var currentBullets
var baseMaxBullets

func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Armory
	turretID = TurretID.SENTRY_TURRET

	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseHealth = maxHealth
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseProjectileSpeed = TurretManager.getTurretStat(turretID,"projectileSpeed")
	baseAttackRange  = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	level = 1
	upgradeTier = 0

	maxBullets = TurretManager.getTurretStat(turretID,"maxBullets")
	shotTime = TurretManager.getTurretStat(turretID,"shotTime")

	projectile = preload("res://Projectile Scenes/sentry bullet.tscn")
	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	selectAreaCollisionShape = $SelectArea/CollisionShape2D
	shootTimer = $ShootTimer
	particle = $TurretTop/AutomatedSentryTurretFire
	shootTimer.wait_time = shotTime
	buildTime = baseBuildTime
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	currentBullets = maxBullets
	baseMaxBullets = maxBullets

	applyUpgrade()

	isPlaced = true

func attack():
	if shotReady and enemiesInRange.size() > 0 and isPlaced and currentBullets > 0 and shootTimer.is_stopped():

		var enemy = EntityManager.getClosestEnemyFromSprite($".")

		if is_instance_valid(enemy) and isPlaced:

			var animInstance = currentBullets % 4

			currentBullets -= 1

			var proj = projectile.instantiate()
			proj.position = position
			proj.velocity = (enemy.global_position - global_position).normalized() * projectileSpeed
			proj.velocity = proj.velocity + Vector2(randf_range(-100,100),randf_range(-100, 100))

			var dif = self.global_position.angle_to_point(enemy.global_position)

			proj.rotation = proj.rotation + dif
			proj.damage = damage
			proj.shooter = self
			get_parent().add_child(proj)
			var mouse_pos = selectArea.get_local_mouse_position()

			# check if mouse is inside each shot and if so then refresh the ui so u can see bullets
			if selectAreaCollisionShape.shape.collide(
				selectAreaCollisionShape.transform, 
				CircleShape2D.new(),
				Transform2D(0, mouse_pos)
			):
				refreshUI(self)
			

			#dif = topSprite.global_position.angle_to_point(enemy.global_position)
			topSprite.look_at(enemy.global_position)
			topSprite.rotate(PI/2)

			
			match animInstance:
				0:
					topSprite.frame = 4
					particle.position.x = 0
				1:
					topSprite.frame = 2
					particle.position.x = 10
				2:
					topSprite.frame = 3
					particle.position.x = -10
				3:
					topSprite.frame = 4
					particle.position.x = 0

			particle.emitting = true

			if currentBullets <= 0:
				reloadTimer.start()
				reloadAnimation()

			shootTimer.start()

func reloadAnimation():

	shotReady = false

	topSprite.frame = 0


func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true
	currentBullets = maxBullets

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	projectileSpeed = (baseProjectileSpeed + (baseProjectileSpeed * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	maxBullets = (baseMaxBullets + (baseMaxBullets * scaleFactor * upgradeTier))
	refreshUI(self)
