extends CPUParticles2D

var particles = [load("res://Particle Scenes/Projectile/Firework/red_explosion.png"),
load("res://Particle Scenes/Projectile/Firework/white_explosion.png"),
load("res://Particle Scenes/Projectile/Firework/blue_explosion.png")]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = particles.pick_random()
