extends Node

var basicSquareHurtParticle = preload("res://Particle Scenes/basic_square_hurt.tscn")
var basicSquareDeathParticle = preload("res://Particle Scenes/basic_square_death.tscn")

func playDamageParticle(enemy):
	
	match enemy.getName():
		
		"Basic Square":
			var particle = basicSquareHurtParticle.instantiate()
			particle.global_position = enemy.global_position
			particle.emitting = true
			get_tree().root.get_node("/root/Game").find_child("CanvasLayer").add_child(particle)
			await get_tree().create_timer(5).timeout
			particle.queue_free()
			
			
func playDeathParticle(enemy):
	
	match enemy.getName():

		"Basic Square":
			var particle = basicSquareDeathParticle.instantiate()
			particle.global_position = enemy.global_position
			particle.emitting = true
			get_tree().root.get_node("/root/Game").find_child("CanvasLayer").add_child(particle)
			await get_tree().create_timer(5).timeout
			particle.queue_free()
