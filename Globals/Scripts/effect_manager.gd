extends Node2D


# Is it more efficient to make seperate dicts for each effect? Or iterate through one dict.....

var enemyCurrentEffects = {} # Format is Enemy Scene : List of current effects
# For instance, Enemy : [["Fire",damage,timer,turretApplied]]
# This is fucking dumb and why object oriented is so much better like my god I could use a struct but no
# this has to be python based
# Bro I spent a solid ass 30 minutes trying to think of a more efficient way than an array of strings in a dict
# I don't know im going insane I'll use this for now

# Okay you know what fine ill make a scene for each effect since its a "class" but then 
# I have to instantiate it (bruh moment) and delete from memory where if I had a struct this would be so easy

# New method... Enemy : [Effect Scene 1, Effect Scene 2,...]
# Honestly this is way better. I could've deleted the comments above but ill keep them to document my sanity

func cleanDict():
	for enemy in enemyCurrentEffects.keys():
		if not is_instance_valid(enemy):
			enemyCurrentEffects.erase(enemy)

func clearEffects(enemy):
	enemyCurrentEffects.erase(enemy)

func removeEffect(enemy,effect):
	enemyCurrentEffects[enemy].erase(effect)

func applyFireEffect(victim,turret,damage,time):
	cleanDict()
	if enemyCurrentEffects.has(victim):
		for effect in enemyCurrentEffects[victim]:
			if effect.getName() == "Fire":
				effect.restartTime(time)
				return
	var fireScene = load("res://Particle Scenes/Effects/fire.tscn")
	var effectScene = fireScene.instantiate()
	effectScene.applyData(turret,victim,damage,time)
	get_tree().root.get_node("/root/Game").find_child("CanvasLayer").add_child(effectScene)
	if enemyCurrentEffects.has(victim):
		enemyCurrentEffects[victim].append(effectScene)
	else:
		enemyCurrentEffects[victim] = [effectScene]
