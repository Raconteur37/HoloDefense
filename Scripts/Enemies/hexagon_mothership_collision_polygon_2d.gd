extends CollisionPolygon2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var radius = 230  # Adjust the radius for the size of the hexagon
	var points = []
	
	for i in range(6):  # 6 points for a hexagon
		var angle = 2 * PI * i / 6  # 360 degrees divided by 6
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		points.append(Vector2(x, y))

	$".".polygon = points  # Set the points of the Polygon2D
