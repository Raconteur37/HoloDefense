extends TileMapLayer

var gridSize = 10
var dic = {}

func _ready() -> void:
	PlacementManager.setCurrentTileMap($".")
