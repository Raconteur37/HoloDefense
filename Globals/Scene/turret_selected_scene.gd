extends Sprite2D

var line2d
var turretName

func buildSelectedTurret(turrName):
	turretName = turrName
	texture = TurretManager.findTurretTexture(turretName)
	line2d = $Line2D
	draw_range_cirle(TurretManager.getTurretStat(turretName,"range"))
	PlacementManager.selectedTurret = self
	PlacementManager.turretSelected = true

func draw_range_cirle(attackRange):

	line2d.clear_points()

	for i in range(32):
		var angle = (i / float(32)) * TAU
		var point = Vector2(cos(angle), sin(angle)) * attackRange
		line2d.add_point(point)

	line2d.add_point(Vector2(cos(0), sin(0)) * attackRange)
	return line2d

func _process(delta: float) -> void:

	if PlacementManager.selectedTurret != null:

		var mousePosition = get_tree().current_scene.get_global_mouse_position()

		PlacementManager.selectedTurret.global_position = PlacementManager.get_snapped_position(mousePosition)
		#global_position = world_pos
