extends Area2D

var turret

func _ready() -> void:
	turret = $".."

func _on_selected() -> void:
	$RangeArea/RangeIndicator.visible = true

func _on_deselected() -> void:
	$RangeArea/RangeIndicator.visible = false
