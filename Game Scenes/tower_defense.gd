extends CanvasLayer

var enableHover
var disableHover

var bottomUI

var turretsAvailableGrid

var placeTurretIconScene = preload("res://Game Scenes/PlaceTurretIcon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enableHover = $HoverControl/Enable
	disableHover = $HoverControl/Disable
	bottomUI = $BottomUI
	turretsAvailableGrid = $BottomUI/TurretsAvailableGrid


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enable_mouse_entered() -> void:
	bottomUI.show()
	buildBottomUI()
	await get_tree().create_timer(.3).timeout
	disableHover.show()
	enableHover.hide()



func _on_disable_mouse_entered() -> void:
	bottomUI.hide()
	await get_tree().create_timer(.3).timeout
	enableHover.show()
	disableHover.hide()

func refreshUI():
	pass

func buildBottomUI():
	for child in turretsAvailableGrid.get_children():
		child.queue_free()
	for turret in GameManager.turretStorage:
		var icon = placeTurretIconScene.instantiate()
		turretsAvailableGrid.add_child(icon)
		icon.setTurret(turret)
