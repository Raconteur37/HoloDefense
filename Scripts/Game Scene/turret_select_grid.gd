extends Control

var fabricationTurret = preload("res://Globals/Scene/FabricationTurret.tscn")

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

var storageButtonOne
var storageButtonTwo
var storageButtonThree
var storageButtonFour
var storageButtonFive
var storageButtonSix
var storageButtonSeven
var storageButtonEight
var storageButtonNine
var storageButtonTen

var storageButtonOneLabel
var storageButtonTwoLabel
var storageButtonThreeLabel
var storageButtonFourLabel
var storageButtonFiveLabel
var storageButtonSixLabel
var storageButtonSevenLabel
var storageButtonEightLabel
var storageButtonNineLabel
var storageButtonTenLabel

var animationPlayer

var storageGrid

var fabricationStart

var turretConveyorItem

# Bro what why are there not queues in godot...I mean it's easy to implement your own but still.....
var maxBuildingQueueSize  = 3
var buildingItems = 0
var buildingItemsQueue = []

var turretsReady = []

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

	storageButtonOne = $"Storage Grid/MarginContainer1/PanelContainer3/StorageTextureButton1"
	storageButtonOneLabel = $"Storage Grid/MarginContainer1/PanelContainer3/StorageTextureButton1/Label1"
	storageButtonTwo = $"Storage Grid/MarginContainer2/PanelContainer/StorageTextureButton2"
	storageButtonTwoLabel = $"Storage Grid/MarginContainer2/PanelContainer/StorageTextureButton2/Label2"
	storageButtonThree = $"Storage Grid/MarginContainer3/PanelContainer/StorageTextureButton3"
	storageButtonThreeLabel = $"Storage Grid/MarginContainer3/PanelContainer/StorageTextureButton3/Label3"
	storageButtonFour = $"Storage Grid/MarginContainer4/PanelContainer/StorageTextureButton4"
	storageButtonFourLabel = $"Storage Grid/MarginContainer4/PanelContainer/StorageTextureButton4/Label4"
	storageButtonFive = $"Storage Grid/MarginContainer5/PanelContainer/StorageTextureButton5"
	storageButtonFiveLabel = $"Storage Grid/MarginContainer5/PanelContainer/StorageTextureButton5/Label5"
	storageButtonSix = $"Storage Grid/MarginContainer6/PanelContainer/StorageTextureButton6"
	storageButtonSixLabel = $"Storage Grid/MarginContainer6/PanelContainer/StorageTextureButton6/Label6"
	storageButtonSeven = $"Storage Grid/MarginContainer7/PanelContainer/StorageTextureButton7"
	storageButtonSevenLabel = $"Storage Grid/MarginContainer7/PanelContainer/StorageTextureButton7/Label7"
	storageButtonEight = $"Storage Grid/MarginContainer8/PanelContainer/StorageTextureButton8"
	storageButtonEightLabel = $"Storage Grid/MarginContainer8/PanelContainer/StorageTextureButton8/Label8"
	storageButtonNine = $"Storage Grid/MarginContainer9/PanelContainer/StorageTextureButton9"
	storageButtonNineLabel = $"Storage Grid/MarginContainer9/PanelContainer/StorageTextureButton9/Label9"
	storageButtonTen = $"Storage Grid/MarginContainer10/PanelContainer/StorageTextureButton10"
	storageButtonTenLabel = $"Storage Grid/MarginContainer10/PanelContainer/StorageTextureButton10/Label10"

	fabricationStart = $FabricationStart

	animationPlayer = $AnimationPlayer

	turretConveyorItem = $"Turret Conveyor Item"

	storageGrid = $"Storage Grid"

func getTurretNameFromStorage(index):

	index = index - 1

	if index < storageDict.size():
		var turretName = storageDict.keys()[index]
		return turretName
	else:
		return null

func addTurretToConstructionQueue(turretIndex : int):

	if buildingItems < maxBuildingQueueSize:

		var turret = TurretManager.getTurret(turretIndex).instantiate()
		var turretCost = turret.getCost()

		if GameManager.getCurrentMoney() >= turretCost:

			GameManager.subtractMoney(turretCost)

			buildingItems += 1

			var fabTurret = fabricationTurret.instantiate()
			fabTurret.turretNumber = turretIndex

			var turretTexture = TurretManager.findTurretTexture(GameManager.turretsNameArray[turretIndex-1])
			var turretBuildTime = turret.baseBuildTime
			fabTurret.constructionTime = turretBuildTime
			fabTurret.turretName = turret.getName()
			fabTurret.global_position = fabricationStart.global_position
			add_child(fabTurret)
			fabTurret.turretConveyorItem.texture = turretTexture

			fabTurret.startConstruction()

			buildingItemsQueue.push_back(fabTurret)

			fabTurret.animationPlayer.speed_scale = float(1 / turretBuildTime)
			fabTurret.animationPlayer.play("Play Conveyor Move")

		else:
			var popupScene = load("res://Globals/Scene/Popup.tscn")
			var popup = popupScene.instantiate()
			popup.global_position = Vector2(get_viewport().size.x / 2, 200)
			popup.insufficientFundsPopup()
			get_tree().current_scene.find_child("CanvasLayer").add_child(popup)

		turret.queue_free()

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

func removeItemFromBuildQueue(item):
	if buildingItemsQueue.has(item):
		buildingItemsQueue.remove_at(buildingItemsQueue.find(item))

func addToStorageDict(turretName):
	if storageDict.has(turretName):
		storageDict[turretName] = storageDict.get(turretName)+1
	else:
		storageDict[turretName] = 1
	updateStorageList()

func updateStorageList():
	var uniqueTurrets = storageDict.keys().size()

	storageButtonOne.hide()
	storageButtonTwo.hide()
	storageButtonThree.hide()
	storageButtonFour.hide()
	storageButtonFive.hide()
	storageButtonSix.hide()
	storageButtonSeven.hide()
	storageButtonEight.hide()
	storageButtonNine.hide()
	storageButtonTen.hide()


	for index in range(uniqueTurrets):
		match index:

			0:
				storageButtonOne.texture_normal = GameManager.findTurretTexture(storageDict.keys()[index])
				var turretAmount = storageDict.get(storageDict.keys()[index])
				storageButtonOneLabel.text = str(turretAmount)
				storageButtonOne.show()
			1:
				storageButtonTwo.texture_normal = GameManager.findTurretTexture(storageDict.keys()[index])
				var turretAmount = storageDict.get(storageDict.keys()[index])
				storageButtonTwoLabel.text = str(turretAmount)
				storageButtonTwo.show()
			2:
				storageButtonThree.texture_normal = GameManager.findTurretTexture(storageDict.keys()[index])
				var turretAmount = storageDict.get(storageDict.keys()[index])
				storageButtonThreeLabel.text = str(turretAmount)
				storageButtonThree.show()
			3:
				storageButtonFour.texture_normal = GameManager.findTurretTexture(storageDict.keys()[index])
				var turretAmount = storageDict.get(storageDict.keys()[index])
				storageButtonFourLabel.text = str(turretAmount)
				storageButtonFour.show()
			4:
				storageButtonFive.texture_normal = GameManager.findTurretTexture(storageDict.keys()[index])
				var turretAmount = storageDict.get(storageDict.keys()[index])
				storageButtonFiveLabel.text = str(turretAmount)
				storageButtonFive.show()
			5:
				storageButtonSix.texture_normal = GameManager.findTurretTexture(storageDict.keys()[index])
				var turretAmount = storageDict.get(storageDict.keys()[index])
				storageButtonSixLabel.text = str(turretAmount)
				storageButtonSix.show()
			6:
				storageButtonSeven.texture_normal = GameManager.findTurretTexture(storageDict.keys()[index])
				var turretAmount = storageDict.get(storageDict.keys()[index])
				storageButtonSevenLabel.text = str(turretAmount)
				storageButtonSeven.show()
			7:
				storageButtonEight.texture_normal = GameManager.findTurretTexture(storageDict.keys()[index])
				var turretAmount = storageDict.get(storageDict.keys()[index])
				storageButtonEightLabel.text = str(turretAmount)
				storageButtonEight.show()
			8:
				storageButtonNine.texture_normal = GameManager.findTurretTexture(storageDict.keys()[index])
				var turretAmount = storageDict.get(storageDict.keys()[index])
				storageButtonNineLabel.text = str(turretAmount)
				storageButtonNine.show()
			9:
				storageButtonTen.texture_normal = GameManager.findTurretTexture(storageDict.keys()[index])
				var turretAmount = storageDict.get(storageDict.keys()[index])
				storageButtonTenLabel.text = str(turretAmount)
				storageButtonTen.show()


func turretPlaced(turretName):
	if storageDict.has(turretName):
		if storageDict.get(turretName) == 1:
			storageDict.erase(turretName)
		else:
			storageDict[turretName] = storageDict.get(turretName)-1
		updateStorageList()

func takeTurretFromStorage(index):

	var turretAmount = storageDict.get(storageDict.keys()[index])

	if turretAmount > 0:
		var turretName = storageDict.keys()[index]

		PlacementManager.selectTurret(turretName)


func _on_storage_texture_button_1_pressed() -> void:
	takeTurretFromStorage(0)

func _on_storage_texture_button_2_pressed() -> void:
	takeTurretFromStorage(1)

func _on_storage_texture_button_3_pressed() -> void:
	takeTurretFromStorage(2)

func _on_storage_texture_button_4_pressed() -> void:
	takeTurretFromStorage(3)

func _on_storage_texture_button_5_pressed() -> void:
	takeTurretFromStorage(4)

func _on_storage_texture_button_6_pressed() -> void:
	takeTurretFromStorage(5)

func _on_storage_texture_button_7_pressed() -> void:
	takeTurretFromStorage(6)

func _on_storage_texture_button_8_pressed() -> void:
	takeTurretFromStorage(7)

func _on_storage_texture_button_9_pressed() -> void:
	takeTurretFromStorage(8)

func _on_storage_texture_button_10_pressed() -> void:
	takeTurretFromStorage(9)
