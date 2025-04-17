extends Node

var basicSquareHurtParticle = preload("res://Particle Scenes/Enemies/basic_square_hurt.tscn")
var basicSquareDeathParticle = preload("res://Particle Scenes/Enemies/basic_square_death.tscn")

var energizedParticle = preload("res://Particle Scenes/Turrets/Energizer Turret/energized.tscn")

var zombieTurnParticle = preload("res://Particle Scenes/Effects/Zombie Turn/ZombieTurnParticle.tscn")

func playDamageParticle(enemy):

	match enemy.getName():

		"Basic Square":
			var particle = basicSquareHurtParticle.instantiate()
			particle.global_position = enemy.global_position
			particle.emitting = true
			get_tree().current_scene.add_child(particle)
			await get_tree().create_timer(5).timeout
			particle.queue_free()


func playDeathParticle(enemy):

	match enemy.getName():

		"Basic Square":
			var particle = basicSquareDeathParticle.instantiate()
			particle.setPosition(enemy.global_position)
			get_tree().current_scene.add_child(particle)

func playZombieTurnParticle(enemy):
	var particle = zombieTurnParticle.instantiate()
	particle.setPosition(enemy.global_position)
	get_tree().current_scene.add_child(particle)

func playExecutionParticle(enemy):

	var executionParticle = load("res://Particle Scenes/Turrets/Reaper Turret/reaper_execute.tscn")
	var particle = executionParticle.instantiate()
	particle.setPosition(enemy.global_position)
	get_tree().current_scene.add_child(particle)


func playEnergizedParticle(turret):

	var particle = energizedParticle.instantiate()
	particle.global_position = turret.global_position
	get_tree().current_scene.add_child(particle)
	turret.currentParticlesMap["Energized"] = particle
