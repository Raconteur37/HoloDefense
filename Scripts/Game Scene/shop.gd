extends Node

@onready var commonShardLabel = $VBoxContainer/HBoxContainer/CommonShardLabel
@onready var rareShardLabel = $VBoxContainer/HBoxContainer2/RareShardLabel
@onready var superRareShardLabel = $VBoxContainer/HBoxContainer3/SuperRareShardLabel
@onready var legendaryShardLabel = $VBoxContainer/HBoxContainer4/LegendaryShardLabel
@onready var unseenShardLabel = $VBoxContainer/HBoxContainer5/UnseenShardLabel
@onready var unstableShardLabel = $VBoxContainer/HBoxContainer6/UnstableShardLabel

@onready var commonFragmentLabel = $VBoxContainer2/HBoxContainer/CommonFragmentLabel
@onready var rareFragmentLabel = $VBoxContainer2/HBoxContainer2/RareFragmentLabel
@onready var superRareFragmentLabel = $VBoxContainer2/HBoxContainer3/SuperRareFragmentLabel
@onready var legendaryFragmentLabel = $VBoxContainer2/HBoxContainer4/LegendaryFragmentLabel
@onready var unseenFragmentLabel = $VBoxContainer2/HBoxContainer5/UnseenFragmentLabel
@onready var unstableFragmentLabel = $VBoxContainer2/HBoxContainer6/UnstableFragmentLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
