extends Turret

class_name FireworkTurret

var reloading : bool = false
var reloadGeneration : int = 0


@export var baseExplosionDamage : float
@export var baseExplosionRadius : float

var shotDelay : float

var shots = 3
var explosionDamage
var explosionRadius

var refundChance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Idk
	turretID = TurretID.FIREWORK_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseHealth = maxHealth
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseProjectileSpeed = TurretManager.getTurretStat(turretID,"projectileSpeed")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	baseReloadTime = TurretManager.getTurretStat(turretID,"reloadTime")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	baseExplosionDamage = TurretManager.getTurretStat(turretID,"explosionDamage")
	baseExplosionRadius = TurretManager.getTurretStat(turretID,"explosionRadius")
	shotDelay = TurretManager.getTurretStat(turretID,"shotDelay")
	refundChance = TurretManager.getTurretStat(turretID,"refundChance")

	level = XpManager.getCurrentLevel(turretID)
	upgradeTier = 0

	projectile = preload("res://Projectile Scenes/firework.tscn")

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
	reloadTime = baseReloadTime
	damage = baseDamage
	projectileSpeed = baseProjectileSpeed
	health = maxHealth
	explosionDamage = baseExplosionDamage
	explosionRadius = baseExplosionRadius

	isPlaced = true

	applyUpgrade()

func attack():
	if shotReady and enemiesInRange.size() > 0 and isPlaced:
		shotReady = false
		var enemy = EntityManager.getClosestEnemyFromSprite($".")
		await get_tree().create_timer(shotDelay).timeout
		shotReady = true
		if is_instance_valid(enemy) and isPlaced:
			var proj = projectile.instantiate()
			applyProjectileModifiers(proj)
			proj.position = position
			proj.velocity = proj.global_position.direction_to(enemy.global_position) * projectileSpeed
			
			var dif = self.global_position.angle_to_point(enemy.global_position)

			proj.rotation = proj.rotation + dif
			proj.damage = damage
			proj.shooter = self
			proj.explosion = true
			proj.explosionDamage = explosionDamage
			proj.explosionRadius = explosionRadius
			get_parent().add_child(proj)

			shots -= 1
			if shots == 0:
				topSprite.frame = 3
			if shots == 1:
				topSprite.frame = 2
			if shots == 2:
				topSprite.frame = 1


			if shots == 0:
				reloadAnimation()

			#dif = topSprite.global_position.angle_to_point(enemy.global_position)
			topSprite.look_at(enemy.global_position)
			topSprite.rotate(PI/2)
	if shots <= 0:
		shotReady = false

func reloadAnimation():
	if not reloading:
		reloadGeneration += 1
		var myGeneration = reloadGeneration
		while shots < 3:
			reloading = true
			await get_tree().create_timer(reloadTime).timeout
			if myGeneration != reloadGeneration:
				return # a refund (or a newer reload cycle) took over mid-wait, this chain is stale
			shots += 1
			shotReady = true
			if shots == 1:
				topSprite.frame = 2
			if shots == 2:
				topSprite.frame = 1
			if shots == 3:
				topSprite.frame = 0
			if enemiesInRange.size() > 0:
				reloading = false
				return
			reloading = false


func tryRefundShot() -> void:
	if shots >= 3:
		return
	if randi_range(1,100) >= refundChance:
		return

	reloadGeneration += 1 
	reloading = false

	shots = min(shots + 1, 3)
	shotReady = true

	if shots == 1:
		topSprite.frame = 2
	if shots == 2:
		topSprite.frame = 1
	if shots == 3:
		topSprite.frame = 0

	refreshUI(self)

	if shots < 3:
		reloadAnimation()

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)

func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)
	if enemiesInRange.size() <= 0 and shots < 3:
		reloadAnimation()

func _on_reload_timer_timeout() -> void:
	shotReady = true


func _on_select_area_mouse_entered() -> void:
	showUI(self)

func _on_select_area_mouse_exited() -> void:
	hideUI()

func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	rangeArea = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	projectileSpeed = (baseProjectileSpeed + (baseProjectileSpeed * scaleFactor * upgradeTier))
	reloadTime = max(1,(baseReloadTime - (baseReloadTime * scaleFactor * upgradeTier)))
	#reloadTimer.wait_time = reloadTime
	explosionRadius = (baseExplosionRadius + (baseExplosionRadius * scaleFactor * upgradeTier))
	explosionDamage = (baseExplosionDamage + (baseExplosionDamage * scaleFactor * upgradeTier))
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	refreshUI(self)
