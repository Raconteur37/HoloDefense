extends Node

var executionParticle = preload("res://Particle Scenes/Turrets/Reaper Turret/reaper_execute.tscn")

var basicSquareHurtParticle = preload("res://Particle Scenes/Enemies/basic_square_hurt.tscn")
var basicSquareDeathParticle = preload("res://Particle Scenes/Enemies/basic_square_death.tscn")
var speedyTriangleDeathParticle = preload("res://Particle Scenes/Enemies/speedy_triangle_death.tscn")
var shootyDiamondDeathParticle = preload("res://Particle Scenes/Enemies/shooty_diamond_death.tscn")
var miniPackedCircleDeathParticle = preload("res://Particle Scenes/Enemies/basic_square_hurt.tscn")

var energizedParticle = preload("res://Particle Scenes/Turrets/Energizer Turret/energized.tscn")
var zombieTurnParticle = preload("res://Particle Scenes/Effects/Zombie Turn/ZombieTurnParticle.tscn")
var healParticle = preload("res://Particle Scenes/Effects/Heal/Heal.tscn")
var bubbleParticle = preload("res://Particle Scenes/Effects/Bubble/Bubble.tscn")
var ignitionsRoundParticle = preload("res://Particle Scenes/Turrets/Flame Turret/flamingTurretEffect.tscn")


# Helper function to find the correct canvas
func get_target_canvas() -> Node:
	var tree = get_tree()
	if not tree:
		return null
		
	var td_canvas = tree.root.find_child("TowerDefenseCanvas", true, false)
	if td_canvas:
		return td_canvas
		
	var current_scene = tree.current_scene
	if current_scene is CanvasLayer:
		return current_scene
	if current_scene:
		var canvas_layers = current_scene.find_children("*", "CanvasLayer")
		if canvas_layers.size() > 0:
			return canvas_layers[0] 
			
	return null


func playDamageParticle(enemy):
	match enemy.getName():
		"Basic Square":
			var canvas = get_target_canvas()
			if not canvas:
				return
				
			var particle = basicSquareHurtParticle.instantiate()
			particle.global_position = enemy.global_position
			particle.emitting = true
			canvas.add_child(particle)
			
			await get_tree().create_timer(5).timeout
			# Ensure the particle still exists before freeing, in case the scene changed
			if is_instance_valid(particle): 
				particle.queue_free()


func playDeathParticle(enemy : Enemy):
	var canvas = get_target_canvas()
	if not canvas:
		return
		
	var particle = null
	match enemy.enemyID:
		Enemy.EnemyID.BASIC_SQUARE:
			particle = basicSquareDeathParticle.instantiate()
		Enemy.EnemyID.SPEEDY_TRIANGLE:
			particle = speedyTriangleDeathParticle.instantiate()
		Enemy.EnemyID.TANKY_RECTANGLE:
			particle = basicSquareDeathParticle.instantiate()
		Enemy.EnemyID.SHOOTY_DIAMOND:
			particle = shootyDiamondDeathParticle.instantiate()
		Enemy.EnemyID.MINI_PACKED_CIRCLE:
			particle = miniPackedCircleDeathParticle.instantiate()
			
	if particle:
		particle.global_position = enemy.global_position
		canvas.add_child(particle)


func playZombieTurnParticle(enemy):
	var canvas = get_target_canvas()
	if canvas:
		var particle = zombieTurnParticle.instantiate()
		particle.global_position = enemy.global_position
		canvas.add_child(particle)


func playExecutionParticle(enemy):
	var canvas = get_target_canvas()
	if canvas:
		var particle = executionParticle.instantiate()
		particle.global_position = enemy.global_position
		canvas.add_child(particle)


func playEnergizedParticle(turret):
	var particle = energizedParticle.instantiate()
	turret.add_child(particle)
	turret.currentParticlesMap["Energized"] = particle


func playIgnitionRoundsParticle(turret):
	var particle = ignitionsRoundParticle.instantiate()
	turret.add_child(particle)
	turret.currentParticlesMap["Ignition Rounds"] = particle


func playBubbleParticle(turret):
	var particle = bubbleParticle.instantiate()
	turret.add_child(particle)
	turret.currentParticlesMap["Bubble"] = particle


func playHealParticle(entity):
	var canvas = get_target_canvas()
	if canvas:
		var particle = healParticle.instantiate()
		particle.global_position = entity.global_position
		canvas.add_child(particle)
