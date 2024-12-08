extends Control

var turretTextures : Array = ["res://Textures/Turrets/Arrow Turret/ArrowTurret.png","res://Textures/Turrets/Energizer Turret/Energizer Turret.png",
"res://Textures/Turrets/Firework Turret/Firework Turret Bottom.png","res://Textures/Turrets/Mini Sentry Turret/MiniSentryTurret.png",
"res://Textures/Turrets/Railgun Turret/RailgunTurret.png","res://Textures/Turrets/Reaper Turret/ReaperTurret.png",
"res://Textures/Turrets/Royal Turret/RoyalTurret.png", "res://Textures/Turrets/Flame Turret/Flame Turret.png",
"res://Textures/Turrets/Spider Turret/Spider Turret.png"]

var textureListCloneOne
var textureListCloneTwo
var textureListCloneThree

var winningTexture
var winningTurret = "Nothing :("

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


func startRoll():
	if not rolling:
		
		winLabel.text = "Rolling..."
		
		var randFloat = randf_range(-99,100)
		
		if randFloat >= 60 and randFloat <= 79.99:
			pickCommonTurret()
			commonWin = true
			win = true
		if randFloat >= 80 and randFloat <= 89.99:
			pickRareTurret()
			rareWin = true
			win = true
		if randFloat >= 90 and randFloat <= 94.99:
			pickSuperRareTurret()
			superRareWin = true
			win = true
		if randFloat >= 95 and randFloat <= 99.4:
			legendaryWin = true
			win = true
		if randFloat >= 99.5:
			unseenWin = true
			win = true
		
		print(winningTurret)
		
		rolling = true
		rollTimer.start()
		await get_tree().create_timer(3).timeout
		slotOne = false
		loadWinningTurretTexture(slotOneTexture)
		await get_tree().create_timer(3).timeout
		slotTwo = false
		loadWinningTurretTexture(slotTwoTexture)
		await get_tree().create_timer(3).timeout
		slotThree = false
		loadWinningTurretTexture(slotThreeTexture)
		if not win:
			var losingTextures = []
			for texture in turretTextures:
				if texture != slotTwoTexture.texture.resource_path:
					losingTextures.append(texture)
			slotThreeTexture.texture = load(losingTextures.pick_random())
		rollTimer.stop()
		
		slotOne = true
		slotTwo = true
		slotThree = true
		
		win = false
		commonWin = false
		rareWin = false
		superRareWin = false
		legendaryWin = false
		unseenWin = false
		
		rolling = false
		
		winLabel.text = str(randFloat) + " You won " + str(winningTurret)
		
		winningTurret = "Nothing :("
		
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

func loadWinningTurretTexture(slot):
	if win:
		slot.texture = load(winningTexture)
		
func pickCommonTurret():
	var commonTurrets = ["Mini Sentry Turret", "Spider Turret"]

	winningTurret = commonTurrets.pick_random()

	match winningTurret:
		
		"Mini Sentry Turret":
			winningTexture = "res://Textures/Turrets/Mini Sentry Turret/MiniSentryTurret.png"
			
		"Spider Turret":
			winningTexture = "res://Textures/Turrets/Spider Turret/Spider Turret.png"
			
func pickRareTurret():
	var rareTurrets = ["Railgun Turret", "Firework Turret", "Energizer Turret", "Flame Turret"]

	winningTurret = rareTurrets.pick_random()
	
	match winningTurret:
		
		"Railgun Turret":
			winningTexture = "res://Textures/Turrets/Railgun Turret/RailgunTurret.png"
			
		"Firework Turret":
			winningTexture = "res://Textures/Turrets/Firework Turret/Firework Turret Bottom.png"
			
		"Energizer Turret":
			winningTexture = "res://Textures/Turrets/Energizer Turret/Energizer Turret.png"
			
		"Flame Turret":
			winningTexture = "res://Textures/Turrets/Flame Turret/Flame Turret.png"

func pickSuperRareTurret():
	var superRareTurrets = ["Reaper Turret", "Royal Turret"]
	
	winningTurret = superRareTurrets.pick_random()
	
	match winningTurret:
		
		"Reaper Turret":
			winningTexture = "res://Textures/Turrets/Reaper Turret/ReaperTurret.png"
		
		"Royal Turret":
			winningTexture = "res://Textures/Turrets/Royal Turret/RoyalTurret.png"
