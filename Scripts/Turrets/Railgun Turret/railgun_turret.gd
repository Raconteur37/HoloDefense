extends Turret

class_name RailgunTurret

@export var basePierce : int

var pierce

var attackedReloadTimeReduction
var killReloadTimeReduction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	projectile = preload("res://Projectile Scenes/railgunbullet.tscn")

	rarity = Rarity.RARE
	type = Type.Armory
	turretID = TurretID.RAILGUN_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseProjectileSpeed = TurretManager.getTurretStat(turretID,"projectileSpeed")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	basePierce = TurretManager.getTurretStat(turretID,"pierce")
	attackedReloadTimeReduction = TurretManager.getTurretStat(turretID,"levelTwoCooldownReduction")
	killReloadTimeReduction = TurretManager.getTurretStat(turretID,"levelThreeCooldownReduction")

	upgradeTier = 0
	level = XpManager.getCurrentLevel(turretID)

	reloadTimer = $ReloadTimer
	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $RailgunTurretTop # CHANGE THIS
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	reloadTime = baseReloadTime
	reloadTimer.wait_time = reloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	baseHealth = maxHealth
	pierce = basePierce

	applyUpgrade()

	isPlaced = true

func attack():

	if shotReady and enemiesInRange.size() > 0 and isPlaced:
		var enemy = EntityManager.getClosestEnemyFromSprite($".")

		shotReady = false
		if is_instance_valid(enemy) and isPlaced:
			var proj = projectile.instantiate()
			applyProjectileModifiers(proj)
			proj.global_position = topSprite.global_position
			proj.pierce = pierce
			proj.velocity = proj.global_position.direction_to(enemy.global_position) * projectileSpeed
			var dif = self.global_position.angle_to_point(enemy.global_position)
			
			proj.rotation = proj.rotation + dif
			proj.damage = damage
			proj.shooter = self
			get_parent().add_child(proj)

			reloadTimer.start(reloadTime)
			reloadAnimation()

			#dif = topSprite.global_position.angle_to_point(enemy.global_position)
			topSprite.look_at(enemy.global_position)
			topSprite.rotate(PI/2)

			$RailgunTurretTop/RailgunShoot.emitting = true

var animGeneration : int = 0 

func reloadAnimation() -> void:
	animGeneration += 1
	topSprite.frame = 1
	stepReloadAnimation(animGeneration)

func stepReloadAnimation(gen: int) -> void:
	if gen != animGeneration:
		return

	if shotReady:
		topSprite.frame = 0
		return

	if reloadTimer.is_stopped():
		topSprite.frame = 0
		return

	var total_frames = 10
	var current_frame = topSprite.frame
	var frames_remaining = total_frames - current_frame
	var time_left = reloadTimer.time_left

	if frames_remaining > 0 and time_left > 0:
		var time_per_frame = time_left / frames_remaining

		get_tree().create_timer(time_per_frame).timeout.connect(func():
			if gen != animGeneration:
				return
			if shotReady:
				topSprite.frame = 0
				return

			topSprite.frame = (topSprite.frame % total_frames) + 1
			stepReloadAnimation(gen)
		)
	else:
		topSprite.frame = 0

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_reload_timer_timeout() -> void:
	shotReady = true
	reloadTimer.wait_time = reloadTime

func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()

func attackedReloadCooldownReduction() -> void:
	if shotReady or reloadTimer.is_stopped():
		return

	var newRemainingTime = reloadTimer.time_left - attackedReloadTimeReduction

	if newRemainingTime > 0:
		reloadTimer.start(newRemainingTime)
		animGeneration += 1
		stepReloadAnimation(animGeneration)
	else:
		reloadTimer.stop()
		animGeneration += 1
		shotReady = true
		reloadTimer.wait_time = reloadTime
		topSprite.frame = 0

func killReloadCooldownReduction() -> void:
	if shotReady or reloadTimer.is_stopped():
		return

	var newRemainingTime = reloadTimer.time_left - killReloadTimeReduction

	if newRemainingTime > 0:
		reloadTimer.start(newRemainingTime)
		animGeneration += 1
		stepReloadAnimation(animGeneration)
	else:
		reloadTimer.stop()
		animGeneration += 1
		shotReady = true
		reloadTimer.wait_time = reloadTime
		topSprite.frame = 0

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	projectileSpeed = (baseProjectileSpeed + (baseProjectileSpeed * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	reloadTimer.wait_time = reloadTime
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	pierce = int((basePierce + (basePierce * scaleFactor * upgradeTier)))
	refreshUI(self)
