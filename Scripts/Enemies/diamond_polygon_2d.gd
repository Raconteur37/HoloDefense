extends Polygon2D


func _ready():
	var radius = 30  # Adjust the radius for the size of the hexagon
	var points = []

	for i in range(4):
		var angle = 2 * PI * i / 4
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		points.append(Vector2(x, y))

	polygon = points  # Set the points of the Polygon2D
	rotate(55)
