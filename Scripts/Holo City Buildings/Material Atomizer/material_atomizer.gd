extends Control

var workArea
var collisionArea

var atomizerSprite

func _ready() -> void:
	workArea = $"Work Area"
	atomizerSprite = $BuildSprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_work_area_body_entered(body: Node2D) -> void:
	if body is Citizen:
		if not body.hasJob:
			body.setJob(Citizen.Job.MATERIAL_ATOMIZER)
		else:
			if body.currentState != Citizen.State.WORKING and body.currentJob == Citizen.Job.MATERIAL_ATOMIZER:
				body.currentState = Citizen.State.WORKING
