extends Node

var executionParticle = preload("res://Particle Scenes/Turrets/Reaper Turret/reaper_execute.tscn")

var basicSquareHurtParticle = preload("res://Particle Scenes/Enemies/basic_square_hurt.tscn")
var basicSquareDeathParticle = preload("res://Particle Scenes/Enemies/basic_square_death.tscn")
var speedyTriangleDeathParticle = preload("res://Particle Scenes/Enemies/speedy_triangle_death.tscn")
var shootyDiamondDeathParticle = preload("res://Particle Scenes/Enemies/shooty_diamond_death.tscn")

var energizedParticle = preload("res://Particle Scenes/Turrets/Energizer Turret/energized.tscn")

var zombieTurnParticle = preload("res://Particle Scenes/Effects/Zombie Turn/ZombieTurnParticle.tscn")

var healParticle = preload("res://Particle Scenes/Effects/Heal/Heal.tscn")

var bubbleParticle = preload("res://Particle Scenes/Effects/Bubble/Bubble.tscn")

func playDamageParticle(enemy):

	match enemy.getName():

		"Basic Square":
			var particle = basicSquareHurtParticle.instantiate()
			particle.global_position = enemy.global_position
			particle.emitting = true
			get_tree().root.find_child("TowerDefenseCanvas", true, false).add_child(particle)
			await get_tree().create_timer(5).timeout
			particle.queue_free()


func playDeathParticle(enemy : Enemy):

	match enemy.enemyID:

		Enemy.EnemyID.BASIC_SQUARE:
			var particle = basicSquareDeathParticle.instantiate()
			particle.global_position = enemy.global_position
			get_tree().root.find_child("TowerDefenseCanvas", true, false).add_child(particle)
		Enemy.EnemyID.SPEEDY_TRIANGLE:
			var particle = speedyTriangleDeathParticle.instantiate()
			particle.global_position = enemy.global_position
			get_tree().root.find_child("TowerDefenseCanvas", true, false).add_child(particle)
		Enemy.EnemyID.SHOOTY_DIAMOND:
			var particle = shootyDiamondDeathParticle.instantiate()
			particle.global_position = enemy.global_position
			get_tree().root.find_child("TowerDefenseCanvas", true, false).add_child(particle)

func playZombieTurnParticle(enemy):
	var particle = zombieTurnParticle.instantiate()
	particle.global_position = enemy.global_position
	get_tree().root.find_child("TowerDefenseCanvas", true, false).add_child(particle)

func playExecutionParticle(enemy):

	var particle = executionParticle.instantiate()
	particle.global_position = enemy.global_position
	get_tree().root.find_child("TowerDefenseCanvas", true, false).add_child(particle)

func playEnergizedParticle(turret):

	var particle = energizedParticle.instantiate()
	#particle.global_position = turret.global_position
	turret.add_child(particle)
	turret.currentParticlesMap["Energized"] = particle

func playBubbleParticle(turret):

	var particle = bubbleParticle.instantiate()
	#particle.global_position = turret.global_position
	turret.add_child(particle)
	turret.currentParticlesMap["Bubble"] = particle

func playHealParticle(entity):

	var particle = healParticle.instantiate()
	particle.global_position = entity.global_position
	get_tree().root.find_child("TowerDefenseCanvas", true, false).add_child(particle)
