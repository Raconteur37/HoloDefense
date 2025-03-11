extends Node2D

var workArea
var collisionArea

var fabricatorSprite

var currentWorkers : Array = [] # Make UI to track current workers that the station

func _ready() -> void:
	workArea = $"Work Area"
	collisionArea = $CollisionShape2D
	fabricatorSprite = $"Sprite"

func _process(delta: float) -> void:
	pass


func _on_work_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Citizen"):
		if body.currentState == "Delivering":
			body.currentState == "Idle"
			body.setWorkDestination()
			print("herer")
