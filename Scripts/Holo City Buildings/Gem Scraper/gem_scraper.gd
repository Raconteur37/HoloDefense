extends Control

var workArea
var collisionArea

var fabricatorSprite

var currentWorkers : Array = [] # Make UI to track current workers that the station

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	workArea = $"Work Area"
	fabricatorSprite = $"Fabricator Sprite"


func _on_work_area_body_entered(body: Node2D) -> void:
	if body is Citizen:
		if not body.hasJob:
			body.setJob(Citizen.Job.GEM_SCRAPER)
		else:
			if body.currentState != Citizen.State.WORKING and body.currentJob == Citizen.Job.GEM_SCRAPER:
				body.currentState = Citizen.State.WORKING
