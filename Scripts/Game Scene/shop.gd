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

@onready var stardustLabel = $HBoxContainer/StardustLabel

@onready var commonShardPurchaseLabel = $HBoxContainer2/CommonShardPurchaseButton/Label7
@onready var rareShardPurchaseLabel = $HBoxContainer2/RareShardPurchaseButton/Label7
@onready var superRarePurchaseLabel = $HBoxContainer2/SuperRareShardPurchaseButton/Label7
@onready var legendaryPurchaseLabel = $HBoxContainer2/LegendaryShardPurchaseButton/Label7
@onready var unseenPurchaseLabel = $HBoxContainer2/UnseenShardPurchaseButton2/Label7

var shopConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateLabels()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func updateLabels():
	commonFragmentLabel.text = str(EconomyManager.get_shard_fragments("common_turret"))
	rareFragmentLabel.text = str(EconomyManager.get_shard_fragments("rare_turret"))
	superRareFragmentLabel.text = str(EconomyManager.get_shard_fragments("super_rare_turret"))
	legendaryFragmentLabel.text = str(EconomyManager.get_shard_fragments("legendary_turret"))
	unseenFragmentLabel.text = str(EconomyManager.get_shard_fragments("unseen_turret"))
	unstableFragmentLabel.text = str(EconomyManager.get_shard_fragments("unstable"))
	
	commonShardLabel.text = str(EconomyManager.get_shards("common_turret"))
	rareShardLabel.text = str(EconomyManager.get_shards("rare_turret"))
	superRareShardLabel.text = str(EconomyManager.get_shards("super_rare_turret"))
	legendaryShardLabel.text = str(EconomyManager.get_shards("legendary_turret"))
	unseenShardLabel.text = str(EconomyManager.get_shards("unseen_turret"))
	unstableShardLabel.text = str(EconomyManager.get_shards("unstable"))
	
	stardustLabel.text = str(EconomyManager.get_stardust())
	
	#commonShardPurchaseLabel.text = str(shopConfig)


func _on_convert_1_pressed() -> void:
	if EconomyManager.get_shard_fragments("common_turret") >= 10:
		EconomyManager.spend_shard_fragments("common_turret",10)
		EconomyManager.add_shards("common_turret",1)
		EconomyManager.save_economy()
	updateLabels()


func _on_convert_2_pressed() -> void:
	if EconomyManager.get_shard_fragments("rare_turret") >= 10:
		EconomyManager.spend_shard_fragments("rare_turret",10)
		EconomyManager.add_shards("rare_turret",1)
		EconomyManager.save_economy()
	updateLabels()


func _on_convert_3_pressed() -> void:
	if EconomyManager.get_shard_fragments("super_rare_turret") >= 10:
		EconomyManager.spend_shard_fragments("super_rare_turret",10)
		EconomyManager.add_shards("super_rare_turret",1)
		EconomyManager.save_economy()
	updateLabels()


func _on_convert_4_pressed() -> void:
	if EconomyManager.get_shard_fragments("legendary_turret") >= 10:
		EconomyManager.spend_shard_fragments("legendary_turret",10)
		EconomyManager.add_shards("legendary_turret",1)
		EconomyManager.save_economy()
	updateLabels()


func _on_convert_5_pressed() -> void:
	if EconomyManager.get_shard_fragments("unseen_turret") >= 10:
		EconomyManager.spend_shard_fragments("unseen_turret",10)
		EconomyManager.add_shards("unseen_turret",1)
		EconomyManager.save_economy()
	updateLabels()


func _on_home_button_pressed() -> void:
	if not $"Slot Machine".is_rolling:
		get_tree().change_scene_to_file("res://Game Scenes/Main Menu.tscn")
