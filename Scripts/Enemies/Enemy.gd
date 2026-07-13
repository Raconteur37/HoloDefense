extends CharacterBody2D

class_name Enemy

enum EnemyID { NONE, BASIC_SQUARE, SPEEDY_TRIANGLE, SHOOTY_DIAMOND, HEXAGON_MOTHERSHIP, TANKY_RECTANGLE, PACKED_CIRCLE, MINI_PACKED_CIRCLE}
enum Type {BASIC, BOSS, ELITE}
enum EliteType {STEEL, TIME_FRACTURED, SUMMONER, WINDY, MENDING, UNSTOPPABLE, PARACASUAL}

var enemyName: String
var health: float
var maxHealth: float
var damage: float
var attackTime: float
var speed: float
var attackRange : float
var projectileSpeed : float
var type : Type
var tier : int
var isElite : bool = false
var eliteType

var sprite : Sprite2D
var hitBoxArea

var destination: Vector2 = Vector2.ZERO
var effects: Dictionary = {} 
var curseDamageAmp: float = 0.0
var isDead: bool = false
var targeted: bool = false
var enemyID: EnemyID
var hurtParticle: CPUParticles2D

# Zombie state
var isZombie: bool = false
var zombieTime : float = false
var initialTurn: bool = false
var turnTurret
var zombieFollowTarget: Enemy = null

var specificDir = null

# Attack logic
var attackReady: bool = true
var attackTimer: Timer
var turretsInRange: Array = []

var stunned : bool = false

var is_sent_enemy: bool = false  

var knockbackVelocity: Vector2 = Vector2.ZERO
var knockbackDecay: float = 1500.0 

var ranged : bool = false

var explosionRadius
var explosionDamage

var minisSpawned

var summonCopyTimer: Timer
var mendingTimer: Timer
var mendingRadius: float = EnemyManager.get_elite_mending_heal_radius()

# Tracking variables for targeting/highlighting
var highlighted: bool = false
var mouseIn : bool = false
var targetting

func _ready() -> void:
	applyScaling()
	attackTimer = Timer.new()
	attackTimer.wait_time = attackTime
	attackTimer.one_shot = true
	attackTimer.timeout.connect(_on_attack_timer_timeout)
	
	add_child(attackTimer)

func _draw() -> void:
	if isElite and eliteType == EliteType.MENDING:
		draw_arc(Vector2.ZERO, mendingRadius, 0.0, TAU, 64, Color(0.2, 0.9, 0.4, 0.6), 3.0)

func _process(delta: float) -> void:
	var is_mouse_near = global_position.distance_to(get_global_mouse_position()) < 50.0
	
	# Highlight if GameManager says we are looking AND the mouse is close enough
	var should_highlight = is_mouse_near and GameManager.turretTargetToggle
	
	if should_highlight != highlighted:
		highlighted = should_highlight
		
		if sprite and sprite.material:
			targetting = true
			sprite.material.set_shader_parameter("is_highlighted", highlighted)
	
	if is_mouse_near and not GameManager.turretTargetToggle and targetting:
		targetting = false
		GameManager.turretTargetting.manualTarget = self

func _physics_process(delta: float) -> void:
	if is_sent_enemy and not multiplayer.is_server():
		return
	
	if knockbackVelocity != Vector2.ZERO and eliteType != EliteType.UNSTOPPABLE:
		knockbackVelocity = knockbackVelocity.move_toward(Vector2.ZERO, knockbackDecay * delta)
	
	if stunned and eliteType != EliteType.UNSTOPPABLE:
		if knockbackVelocity != Vector2.ZERO:
			knockbackVelocity = knockbackVelocity.move_toward(Vector2.ZERO, knockbackDecay * delta)
			velocity = knockbackVelocity
			move_and_slide() 
		return

	updateDestination()

	turretsInRange = turretsInRange.filter(func(t): return is_instance_valid(t))

	if turretsInRange.size() > 0 and not isZombie:
		velocity = Vector2.ZERO
		
		if attackReady and not ranged:
			var targetTurret = turretsInRange[0]
			EntityManager.turretTakeDamage(damage, targetTurret, null, self)
			startAttackCooldown()
	else:
		move()

	if isZombie and not initialTurn and type != Type.BOSS:
		initZombie()

func updateDestination() -> void:
	if zombieFollowTarget != null:
		if not is_instance_valid(zombieFollowTarget) or zombieFollowTarget.isDead:
			zombieFollowTarget = GameManager.getRandomEnemyAlive()
		if zombieFollowTarget != null:
			destination = zombieFollowTarget.global_position
	elif destination == Vector2.ZERO:
		getDestination()

func move() -> void:
	if destination == Vector2.ZERO:
		return
		
	var direction = (destination - global_position).normalized()
	
	velocity = (direction * speed) + knockbackVelocity
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		
		if collider.is_in_group("Turret") or collider.is_in_group("Minion"):
			if not isZombie:
				var impact_angle = direction.dot(col.get_normal())
				
				if impact_angle < -0.4:
					velocity = Vector2.ZERO
					
					if attackReady:
						EntityManager.turretTakeDamage(damage, collider, null, self)
						startAttackCooldown()
					return

func initZombie() -> void:
	if not is_instance_valid(turnTurret):
		return
	initialTurn = true
	WaveManager.removeActiveEnemy(self)
	modulate = Color(0.085, 0.987, 0.138, 1.0)
	spawnZombieArea()
	destination = EnemySpawnManager.getRandomOffscreenPosition()
	set_collision_layer_value(3,false)
	set_collision_layer_value(1,true)
	set_collision_mask_value(1,false)
	set_collision_mask_value(2,false)
	
func spawnZombieArea() -> void:
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 75
	shape.shape = circle
	area.set_collision_layer_value(1, true)
	area.set_collision_mask_value(3, true)
	area.add_child(shape)
	area.body_entered.connect(onZombieAreaEntered)
	area.body_exited.connect(onZombieAreaExit)
	add_child(area)

func onZombieAreaEntered(body: Node) -> void:
	if not body.is_in_group("Enemy") or body.isZombie:
		return
	var chance = turnTurret.get("turnChance") if is_instance_valid(turnTurret) else 10
	if randi_range(0, 100) <= chance:
		if is_instance_valid(turnTurret):
			EffectManager.applyZombifyEffect(body,turnTurret,turnTurret.turnTime)
			StatManager.addStat(turnTurret.turretID,"enemies_zombified",1)
			XpManager.addXp(turnTurret.turretID)

func onZombieAreaExit(_body: Node) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Turret") and not turretsInRange.has(body):
		turretsInRange.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Turret"):
		turretsInRange.erase(body)

func startAttackCooldown() -> void:
	if type != Type.BOSS and attackTimer != null:
		attackReady = false
		attackTimer.start()

func _on_attack_timer_timeout() -> void:
	attackReady = true

func getDestination() -> void:
	if specificDir != null:
		destination = specificDir
	else:
		destination = get_viewport().get_visible_rect().size / 2

func getName() -> String:
	return enemyName

func applyScaling() -> void:
	var priorSystems = max(0, WaveManager.systemNumber - 1)
	var totalWaves = (priorSystems * WaveManager.getWavesPerSystem()) + WaveManager.currentWave - 1

	var waveHealthMult = pow(WaveManager.getHealthScalePerWave(), totalWaves)
	var waveDamageMult = pow(WaveManager.getDamageScalePerWave(), totalWaves)

	var systemHealthMult = WaveManager.getScaledSystemHealthMultiplier()
	var systemDamageMult = WaveManager.getScaledSystemDamageMultiplier()
	var systemSpeedMult = WaveManager.getScaledSystemSpeedMultiplier()

	health *= (waveHealthMult * systemHealthMult)
	damage *= (waveDamageMult * systemDamageMult)
	speed *= systemSpeedMult 

	health = round(health)
	damage = round(damage)

func applyKnockback(origin_pos: Vector2, strength: float) -> void:
	var push_direction = (global_position - origin_pos).normalized()
	knockbackVelocity = push_direction * strength

func getEnemyTier():
	return tier

func rollForElite() -> void:
	if type == Type.BOSS:
		return
		
	if WaveManager.systemNumber >= WaveManager.getEliteSystemThresh():
		var priorSystems = max(0, WaveManager.systemNumber - 1)
		var totalWaves = (priorSystems * WaveManager.getWavesPerSystem()) + WaveManager.currentWave - 1
		
		var chance = WaveManager.getScaledEliteChance(WaveManager.currentDifficulty, totalWaves)
		
		if randf_range(0.0, 100.0) <= chance:
			type = Type.ELITE
			isElite = true
			
			var all_elite_types = EliteType.values()
			eliteType = all_elite_types[randi() % all_elite_types.size()]
			
			setElite()
			
			if not SettingsManager.has_seen_enemy(eliteType):
				SettingsManager.mark_enemy_seen(eliteType)
				var enemyPopupScene = load("res://Game Scenes/EnemyInfoPopup.tscn").instantiate()
				get_tree().current_scene.add_child(enemyPopupScene)
				enemyPopupScene.buildElitePopup(eliteType)

func setElite():
	match eliteType:
		EliteType.STEEL:
			sprite.material.set_shader_parameter("is_steel", true)
		EliteType.TIME_FRACTURED:
			var allCitizens = get_tree().get_nodes_in_group("Citizen")
			for citizen : Citizen in allCitizens:
				citizen.frozen = true
			sprite.material.set_shader_parameter("is_time_fractured", true)
		EliteType.SUMMONER:
			sprite.material.set_shader_parameter("is_summoner", true)
			summonCopy()
		EliteType.WINDY:
			sprite.material.set_shader_parameter("is_windy", true)
			speed += speed * EnemyManager.get_elite_windy_speed_increase()
		EliteType.MENDING:
			sprite.material.set_shader_parameter("is_mending", true)
			startMending()
		EliteType.UNSTOPPABLE:
			sprite.material.set_shader_parameter("is_unstoppable", true)
			health += maxHealth * EnemyManager.get_absorbent_health_increase()
		EliteType.PARACASUAL:
			sprite.material.set_shader_parameter("is_paracasual", true)
			damage = 999999

func summonCopy() -> void:
	if summonCopyTimer != null:
		return
		
	var spawnInterval = EnemyManager.get_elite_summoner_spawn_interval()
	
	summonCopyTimer = Timer.new()
	summonCopyTimer.wait_time = spawnInterval
	summonCopyTimer.one_shot = false 
	summonCopyTimer.timeout.connect(_on_summon_timer_timeout)
	
	add_child(summonCopyTimer)
	summonCopyTimer.start()

func _on_summon_timer_timeout() -> void:
	if isDead or stunned or isZombie:
		return
		
	var alliesCount = EnemyManager.get_elite_summoner_allies_summoned()
	
	for i in range(alliesCount):
		EnemySpawnManager.summonCopy(self,self.enemyID)

func startMending() -> void:
	if mendingTimer != null:
		return
		
	var healInterval = EnemyManager.get_elite_mending_heal_interval()
	
	mendingTimer = Timer.new()
	mendingTimer.wait_time = healInterval
	mendingTimer.one_shot = false
	mendingTimer.timeout.connect(_on_mending_timer_timeout)
	
	add_child(mendingTimer)
	mendingTimer.start()

func _on_mending_timer_timeout() -> void:
	if isDead or stunned:
		return
		
	var heal_amount_pct = EnemyManager.get_elite_mending_heal_amount()
	var all_enemies = get_tree().get_nodes_in_group("Enemy")
	
	for e in all_enemies:
		if is_instance_valid(e) and not e.isDead and not e.isZombie:
			if global_position.distance_to(e.global_position) <= mendingRadius:
				e.health += (e.maxHealth * heal_amount_pct)
				if e.health > e.maxHealth:
					e.health = e.maxHealth


func set_highlighted(is_high: bool) -> void:
	highlighted = is_high
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("is_highlighted", highlighted)

func highlight_target(is_targeted: bool) -> void:
	if is_targeted:
		if sprite and sprite.material:
			sprite.material.set_shader_parameter("is_targeted", true)
	else:
		if sprite and sprite.material:
			sprite.material.set_shader_parameter("is_targeted", false)

# --- Mouse Detection Signals ---

func _on_hitbox_area_mouse_entered() -> void:
	mouseIn = true

func _on_hitbox_area_mouse_exited() -> void:
	mouseIn = false
