extends Control

var turretButtonOne
var turretButtonTwo
var turretButtonThree
var turretButtonFour
var turretButtonFive
var turretButtonSix
var turretButtonSeven
var turretButtonEight
var turretButtonNine
var turretButtonTen

var animationPlayer

var storageGrid

var turretConveyorItem

# Bro what why are there not queues in godot...I mean it's easy to implement your own but still.....
var maxBuildingQueueSize  = 1
var buildingItems = 0
var buildingItemsQueue = []

var storageDict = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	turretButtonOne = $"Turret Button Grid/MarginContainer/PanelContainer3/TextureButton1"
	turretButtonTwo = $"Turret Button Grid/MarginContainer2/PanelContainer/TextureButton2"
	turretButtonThree = $"Turret Button Grid/MarginContainer3/PanelContainer/TextureButton3"
	turretButtonFour = $"Turret Button Grid/MarginContainer4/PanelContainer/TextureButton4"
	turretButtonFive = $"Turret Button Grid/MarginContainer5/PanelContainer/TextureButton5"
	turretButtonSix = $"Turret Button Grid/MarginContainer6/PanelContainer/TextureButton6"
	turretButtonSeven = $"Turret Button Grid/MarginContainer7/PanelContainer/TextureButton7"
	turretButtonEight = $"Turret Button Grid/MarginContainer8/PanelContainer/TextureButton8"
	turretButtonNine = $"Turret Button Grid/MarginContainer9/PanelContainer/TextureButton9"
	turretButtonTen = $"Turret Button Grid/MarginContainer10/PanelContainer/TextureButton10"
	
	animationPlayer = $AnimationPlayer
	
	turretConveyorItem = $"Turret Conveyor Item"

	storageGrid = $"Storage Grid"


func addTurretToConstructionQueue(turretIndex : int):
	
	if buildingItems < maxBuildingQueueSize:
		
		buildingItems += 1
		
		var turretTexture = GameManager.findTurretTexture(GameManager.turretsNameArray[turretIndex-1])
		var turret = GameManager.getTurret(turretIndex).instantiate()
		get_tree().current_scene.find_child("CanvasLayer").add_child(turret)
		var turretBuildTime = turret.baseBuildTime
		
		turret.startConstruction()
		buildingItemsQueue.push_back(turret)
		
		turretConveyorItem.texture = turretTexture
		
		animationPlayer.speed_scale = float(1 / turretBuildTime)
		
		animationPlayer.play("Turret Conveyor Move")

func _on_texture_button_1_pressed() -> void:
	addTurretToConstructionQueue(1)

func _on_texture_button_2_pressed() -> void:
	addTurretToConstructionQueue(2)

func _on_texture_button_3_pressed() -> void:
	addTurretToConstructionQueue(3)

func _on_texture_button_4_pressed() -> void:
	addTurretToConstructionQueue(4)

func _on_texture_button_5_pressed() -> void:
	addTurretToConstructionQueue(5)

func _on_texture_button_6_pressed() -> void:
	addTurretToConstructionQueue(6)

func _on_texture_button_7_pressed() -> void:
	addTurretToConstructionQueue(7)

func _on_texture_button_8_pressed() -> void:
	addTurretToConstructionQueue(8)

func _on_texture_button_9_pressed() -> void:
	addTurretToConstructionQueue(9)

func _on_texture_button_10_pressed() -> void:
	addTurretToConstructionQueue(10)
	var index = 0
	while index < buildingItemsQueue.size():
		var x = buildingItemsQueue[index]
		if x.constructed:
			if storageDict.has(x.getName()):
				storageDict[x.getName()].append(1)
			else:
				storageDict[x.getName()] = [storageDict.get(x.getName())+1]
			buildingItemsQueue.remove_at(index)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Turret Conveyor Move":
		buildingItems -= 1
		for x in buildingItemsQueue:
			print(x.constructed)
