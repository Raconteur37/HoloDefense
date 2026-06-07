extends Node

var enemiesKilledTotal = 0

var enemiesKilled : Dictionary = {}

var stardust = 0
var stardustEarned = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func enemyKilled(enemyID : Enemy.EnemyID):
	enemiesKilledTotal += 1
	if enemiesKilled.has(enemyID):
		enemiesKilled[enemyID] += enemiesKilled.get(enemyID) + 1
	else:
		enemiesKilled[enemyID] = 1


func reset():
	stardustEarned = 0
	enemiesKilledTotal = 0
