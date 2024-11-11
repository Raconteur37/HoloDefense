extends CollisionPolygon2D


func _ready():
	var radius = 15  # Adjust the radius for the size of the hexagon
	var points = []
	
	for i in range(3):  
		var angle = 2 * PI * i / 3  
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		points.append(Vector2(x, y))

	polygon = points  # Set the points of the Polygon2D
