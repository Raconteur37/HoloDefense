extends CharacterBody2D

var workArea
var collisionArea

var fabricatorSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	workArea = $"Work Area"
	collisionArea = $CollisionShape2D
	fabricatorSprite = $"Fabricator Sprite"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_work_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Citizen"):
		if not body.hasJob:
			body.setJob("Gem Scraper")
