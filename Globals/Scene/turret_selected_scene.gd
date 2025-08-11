extends Sprite2D

var line2d

func buildSelectedTurret(turretName,attackRange):
	texture = TurretManager.findTurretTexture(turretName)
	line2d = $Line2D
	draw_range_cirle(attackRange)

func draw_range_cirle(attackRange):

	line2d.clear_points()

	for i in range(32):
		var angle = (i / float(32)) * TAU
		var point = Vector2(cos(angle), sin(angle)) * attackRange
		line2d.add_point(point)

	line2d.add_point(Vector2(cos(0), sin(0)) * attackRange)
	return line2d
