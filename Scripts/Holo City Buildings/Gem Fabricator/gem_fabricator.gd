extends Node2D

var workArea
var collisionArea

var fabricatorSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	workArea = $"Work Area"
	collisionArea = $"Collision Area"
	fabricatorSprite = $"Fabricator Sprite"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
