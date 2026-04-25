extends Turret

class_name FlameTurret

var shooting : bool = false

var turretBeam
var damageTickTimer

@export var baseFireDamage : float
@export var baseFireTime : float
@export var baseDamageTickTime : float

var particleVelocity = 200

var fireDamage
var fireTime
var damageTickTime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rarity = Rarity.RARE
	type = Type.Elemental
	turretID = TurretID.FLAME_TURRET
	turretName = TurretManager.getTurretStat(turretID,"name")
	price = TurretManager.getTurretStat(turretID,"price")
	maxHealth = TurretManager.getTurretStat(turretID,"health")
	baseDamage = TurretManager.getTurretStat(turretID,"damage")
	baseAttackRange = TurretManager.getTurretStat(turretID,"range")
	armor = TurretManager.getTurretStat(turretID,"armor")
	baseBuildTime = TurretManager.getTurretStat(turretID,"constructionTime")
	baseFireDamage = TurretManager.getTurretStat(turretID,"fireDamage")
	baseFireTime = TurretManager.getTurretStat(turretID,"fireTime")
	baseDamageTickTime = TurretManager.getTurretStat(turretID,"fireTickTime")
	level = 1
	upgradeTier = 0

	line2d = $RangeArea/RangeIndicator
	var rangeShapeDup = $RangeArea/CollisionShape2D.shape.duplicate()
	rangeCollisionShape = $RangeArea/CollisionShape2D
	rangeCollisionShape.shape = rangeShapeDup
	rangeIndicator = $RangeArea/RangeIndicator
	topSprite = $TurretTop
	selectArea = $SelectArea
	bodyCollisionShape = $CollisionShape2D
	turretBeam = $TurretTop/FlameArea/FlameAreaShape2D
	damageTickTimer = $DamageTickTimer
	attackRange = baseAttackRange
	line2d = TurretManager.draw_range_circle(line2d,attackRange)
	rangeCollisionShape.shape.radius = attackRange
	damage = baseDamage
	health = maxHealth
	fireDamage = baseFireDamage
	fireTime = baseFireTime
	damageTickTime = baseDamageTickTime
	damageTickTimer.wait_time = damageTickTime

	hit.connect(EntityManager.entityTakeDamage)
	upgrade.connect(EntityManager.applyUpgradeTier)

	upgradeTier = EntityManager.getUpgradeTier(turretName)

	for x in range(upgradeTier):
		upgrade.emit(self)

	if DeveloperMode.inDevMode:
		isPlaced = true
		GameManager.addTurretToDict(self)
		health = 9999
	if GameManager.previewMode:
		var dummy = load("res://Enemy Scenes/Dummy.tscn")
		dummy = dummy.instantiate()
		dummy.global_position = to_local(global_position)
		dummy.global_position.x += 80
		add_child(dummy)


func _process(delta: float) -> void:
	if enemiesInRange.size() > 0 and not shooting:
		shooting = true
		if $DamageTickTimer.is_stopped():
			$DamageTickTimer.start()
	if enemiesInRange.size() <= 0:
		shooting = false
	if shooting and enemiesInRange.size() > 0 and isPlaced:
		var enemy = EntityManager.getClosestEnemyFromSprite($".")
		topSprite.look_at(enemy.global_position)
		#topSprite.rotate(PI/2)
		$"TurretTop/Flame Particle".emitting = true
	if not shooting:
		$DamageTickTimer.stop()
		$"TurretTop/Flame Particle".emitting = false

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
		for x in $TurretTop/FlameArea.get_overlapping_areas():
			if x.get_parent().is_in_group("Enemy"):
				x.get_parent().hit.emit(damage,self,x.get_parent(),turretBeam)
				EffectManager.applyFireEffect(x.get_parent(),self,fireDamage,fireTime)
		damageTickTimer.start()


func _on_select_area_mouse_entered() -> void:
	showUI(self)


func _on_select_area_mouse_exited() -> void:
	hideUI()
