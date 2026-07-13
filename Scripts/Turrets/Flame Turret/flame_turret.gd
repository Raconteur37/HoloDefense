extends Turret

class_name FlameTurret

var shooting : bool = false

var turretBeam
var damageTickTimer
var flameArea
var flameAreaShape
var flameParticle

@export var baseFireDamage : float
@export var baseFireTime : float
@export var baseDamageTickTime : float

var particleVelocity = 200

var fireDamage
var fireTime
var damageTickTime

var ignitionRoundsTime
var baseIgnitionRoundsTime

var explosionRange
var baseExplosionRange

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Elemental
	turretID = TurretID.FLAME_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseHealth = maxHealth
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	scaleFactor = TurretManager.getTurretStat(turretID,"scaleFactor")
	baseFireDamage = TurretManager.getTurretStat(turretID,"fireDamage")
	baseFireTime = TurretManager.getTurretStat(turretID,"fireTime")
	baseDamageTickTime = EffectManager.getEffectStat(EffectClass.Effect.BURN,"tickTime")
	baseIgnitionRoundsTime = TurretManager.getTurretStat(turretID,"ignitionRoundsTime")
	baseExplosionRange = TurretManager.getTurretStat(turretID,"flameExplosionRange")

	level = XpManager.getCurrentLevel(turretID)
	upgradeTier = 0

	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	bottomSprite = $TurretBottom
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	turretBeam = $TurretTop/FlameArea/FlameAreaShape2D
	damageTickTimer = $DamageTickTimer
	flameArea = $TurretTop/FlameArea
	flameAreaShape = $TurretTop/FlameArea/FlameAreaShape2D
	flameParticle = $"TurretTop/Flame Particle"
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	damage = baseDamage
	health = maxHealth
	fireDamage = baseFireDamage
	fireTime = baseFireTime
	damageTickTime = baseDamageTickTime
	damageTickTimer.wait_time = damageTickTime
	ignitionRoundsTime = baseIgnitionRoundsTime
	explosionRange = baseExplosionRange

	isPlaced = true

	applyUpgrade()
	


func _process(delta: float) -> void:
	if enemiesInRange.size() > 0 and not shooting:
		shooting = true
		if damageTickTimer.is_stopped():
			damageTickTimer.start()
	if enemiesInRange.size() <= 0:
		shooting = false
	if shooting and enemiesInRange.size() > 0 and isPlaced:
		var enemy = EntityManager.getClosestEnemyFromSprite($".")
		topSprite.look_at(enemy.global_position)
		#topSprite.rotate(PI/2)
		flameParticle.emitting = true
	if not shooting:
		damageTickTimer.stop()
		flameParticle.emitting = false

func openSelectedMenu():
	if isPlaced:
		var description = load("res://Globals/Scene/TurretDescription/TurretDescriptionScene.tscn")
		menu = description.instantiate()
		get_parent().add_child(menu)
		menu.buildContainer(self)
		showRange()

func _on_range_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Enemy")):
		enemiesInRange.append(body)


func _on_range_area_body_exited(body: Node2D) -> void:
	enemiesInRange.erase(body)

func _on_damage_tick_timer_timeout() -> void:
	if shooting:
		for area in flameArea.get_overlapping_areas():
			var enemy = area.get_parent()
			if enemy.is_in_group("Enemy"):
				EntityManager.enemyTakeDamage(DamagePacket.new(damage, DamagePacket.Type.TURRET, self, [], {}), enemy)
				EffectManager.applyBurnEffect(enemy,self,fireDamage,fireTime)
		damageTickTimer.start()


func applyUpgrade():
	upgradeTier = GameManager.getTurretTempLevel(turretID)
	damage = (baseDamage + (baseDamage * scaleFactor * upgradeTier))
	attackRange = (baseAttackRange + (baseAttackRange * scaleFactor * upgradeTier))
	maxHealth = (baseHealth + (baseHealth * scaleFactor * upgradeTier))
	health = maxHealth
	fireTime = (baseFireTime + (baseFireTime * scaleFactor * upgradeTier))
	fireDamage = (baseFireDamage + (baseFireDamage * scaleFactor * upgradeTier))
	explosionRange = (baseExplosionRange + (baseExplosionRange * scaleFactor * upgradeTier))
	ignitionRoundsTime = (baseIgnitionRoundsTime + (baseIgnitionRoundsTime * scaleFactor * upgradeTier))
	particleVelocity += 10
	flameArea.position.x += .4
	flameAreaShape.shape.height += .8
	flameParticle.process_material.set("initial_velocity",Vector2(particleVelocity,particleVelocity))
	refreshUI(self)
