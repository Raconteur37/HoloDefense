extends CharacterBody2D

class_name Minion

var turretOwner : Turret

var maxHealth : float
var minionName : String
var attackTime : float
var speed : float
var health : float
var damage : float
var sprite

var id : MinionID

enum MinionID {
	NONE,
	KNIGHT,
	ARCHER,
	BARD
}

func death():
	turretOwner.removeMinion(self)
	queue_free()
