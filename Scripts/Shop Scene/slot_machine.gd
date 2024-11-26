extends Control

var turretTextures : Array = ["res://Textures/Turrets/Arrow Turret/ArrowTurret.png","res://Textures/Turrets/Energizer Turret/Energizer Turret.png",
"res://Textures/Turrets/Firework Turret/Firework Turret Bottom.png","res://Textures/Turrets/Mini Sentry Turret/MiniSentryTurret.png",
"res://Textures/Turrets/Railgun Turret/RailgunTurret.png","res://Textures/Turrets/Reaper Turret/ReaperTurret.png",
"res://Textures/Turrets/Royal Turret/RoyalTurret.png"]

var textureListCloneOne
var textureListCloneTwo
var textureListCloneThree

var rollTimer
var winLabel

var rolling : bool = false

var slotOne = true
var slotTwo = true
var slotThree = true

var slotOneTexture
var slotTwoTexture
var slotThreeTexture

var win : bool = false
var commonWin : bool = false
var rareWin : bool = false
var superRareWin : bool = false
var legendaryWin : bool = false
var unseenWin : bool = false

func _ready() -> void:
	rollTimer = $"Roll Timer"
	slotOneTexture = $HBoxContainer/MarginContainer/TextureRect
	slotTwoTexture = $HBoxContainer/MarginContainer2/TextureRect
	slotThreeTexture = $HBoxContainer/MarginContainer3/TextureRect
	winLabel = $WinLabel
	textureListCloneOne = turretTextures.duplicate()
	textureListCloneTwo = turretTextures.duplicate()
	textureListCloneThree = turretTextures.duplicate()

func pickCommonTurret():
	pass


func startRoll():
	if not rolling:
		
		winLabel.text = "Rolling..."
		
		var randFloat = randf_range(1,100)
		
		if randFloat >= 60 and randFloat <= 79.99:
			commonWin = true
		if randFloat >= 80 and randFloat <= 89.99:
			rareWin = true
		if randFloat >= 90 and randFloat <= 94.99:
			superRareWin = true
		if randFloat >= 95 and randFloat <= 99.4:
			legendaryWin = true
		if randFloat >= 99.5:
			unseenWin = true
		
		rolling = true
		rollTimer.start()
		await get_tree().create_timer(3).timeout
		slotOne = false
		await get_tree().create_timer(3).timeout
		slotTwo = false
		await get_tree().create_timer(3).timeout
		slotThree = false
		rollTimer.stop()
		
		slotOne = true
		slotTwo = true
		slotThree = true
		
		rolling = false
		
		winLabel.text = str(randFloat)
		
func _on_button_pressed() -> void:
	startRoll()

func _on_roll_time_timeout() -> void:
	if slotOne:
		var randNum = randi() % (textureListCloneOne.size() - 2)
		var rand = (textureListCloneOne[randNum])
		slotOneTexture.texture = load(rand)
		textureListCloneOne.remove_at(randNum)
		textureListCloneOne.append(rand)
	if slotTwo:
		var randNum = randi() % (textureListCloneTwo.size() - 2)
		var rand = (textureListCloneTwo[randNum])
		slotTwoTexture.texture = load(rand)
		textureListCloneTwo.remove_at(randNum)
		textureListCloneTwo.append(rand)
	if slotThree:
		var randNum = randi() % (textureListCloneThree.size() - 2)
		var rand = (textureListCloneThree[randNum])
		slotThreeTexture.texture = load(rand)
		textureListCloneThree.remove_at(randNum)
		textureListCloneThree.append(rand)
