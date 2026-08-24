extends Control

@onready var popup = $Popup

@onready var button = preload("res://Holo City Buildings/EnemySynthButton.tscn")
@onready var card = preload("res://Holo City Buildings/EnemySynthQueue.tscn")

@onready var gridContainer = $Popup/GridContainer
@onready var enemyPurchaseGrid = $Popup/EnemiesPurchasedGrid

@onready var readyQueue = {} # A dict with the key of the enemy and value of another dict

var currentPriceMult = 0

var steelElite : bool = false
var summonerElite : bool = false
var windyElite : bool = false

@onready var steelToggle = $Popup/CheckBoxContainer/HBoxContainer/SteelElite
@onready var summonerToggle = $Popup/CheckBoxContainer/HBoxContainer2/SummonerElite
@onready var windyToggle = $Popup/CheckBoxContainer/HBoxContainer3/WindyElite

# this is so we can hold elite data
# {Enemy.BASIC_SQUARE : {regular : 10, steel_elite : 10}}

func _on_select_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			popup.show()
			buildEnemyButtons()

func _ready() -> void:
	if GameManager.VSmode:
		visible = true
	else:
		visible = false


func _on_popup_visibility_changed() -> void:
	pass

func attemptBuy(enemyID : Enemy.EnemyID, cost : int):
	if currentPriceMult != 0:
		cost = cost * currentPriceMult
	CityManager.currentScrap = 999
	if CityManager.currentScrap >= cost:
		CityManager.currentScrap -= cost
		if steelElite:
			addEnemyToQueue(enemyID,Enemy.EliteType.STEEL)
			return
		if summonerElite:
			addEnemyToQueue(enemyID,Enemy.EliteType.SUMMONER)
			return
		if windyElite:
			addEnemyToQueue(enemyID,Enemy.EliteType.WINDY)
			return
		addEnemyToQueue(enemyID,Enemy.EliteType.NONE)
	updateUI()



func addEnemyToQueue(enemyID: Enemy.EnemyID, eliteType: Enemy.EliteType):
	if not readyQueue.has(enemyID):
		readyQueue[enemyID] = {}
		
	if not readyQueue[enemyID].has(eliteType):
		readyQueue[enemyID][eliteType] = 0
		
	readyQueue[enemyID][eliteType] += 1

	updateUI()


func updatePrices():
	if currentPriceMult == 0:
		for but in gridContainer.get_children():
			but.resetPrice()
	else:
		for but in gridContainer.get_children():
			but.updatePrice(currentPriceMult)


func updateUI():
	for child in enemyPurchaseGrid.get_children():
		child.queue_free()
		
	for enemyID in readyQueue:
		var eliteVariants = readyQueue[enemyID]
		
		for eliteType in eliteVariants:
			var amount = eliteVariants[eliteType]
			
			var cardInstance = card.instantiate()
			enemyPurchaseGrid.add_child(cardInstance)
			cardInstance.buildCard(enemyID, amount, eliteType)

func buildEnemyButtons():
	for child in gridContainer.get_children():
		child.queue_free()
	for enemy in EnemyManager.get_enemies_with_cost_list():
		var but = button.instantiate()
		gridContainer.add_child(but)
		but.buildButton(enemy)



func _on_steel_elite_toggled(toggled_on: bool) -> void:
	if toggled_on:
		summonerToggle.button_pressed = false
		windyToggle.button_pressed = false
		steelElite = true
		currentPriceMult = EnemyManager.get_elite_cost_multiplier(Enemy.EliteType.STEEL)
	else:
		steelElite = false
		currentPriceMult = 0
	updatePrices()


func _on_summoner_elite_toggled(toggled_on: bool) -> void:
	if toggled_on:
		steelToggle.button_pressed = false
		windyToggle.button_pressed = false
		summonerElite = true
		currentPriceMult = EnemyManager.get_elite_cost_multiplier(Enemy.EliteType.SUMMONER)
	else:
		summonerElite = false
		currentPriceMult = 0
	updatePrices()


func _on_windy_elite_toggled(toggled_on: bool) -> void:
	if toggled_on:
		summonerToggle.button_pressed = false
		steelToggle.button_pressed = false
		windyElite = true
		currentPriceMult = EnemyManager.get_elite_cost_multiplier(Enemy.EliteType.WINDY)
	else:
		windyElite = false
		currentPriceMult = 0
	updatePrices()


func _on_send_wave_pressed() -> void:
	var target_peer = SteamManager.get_opponent_id()
	
	if target_peer == 0:
		push_warning("EnemySynth: No opponent found in lobby!")
		return

	for enemyID in readyQueue:
		var eliteVariants = readyQueue[enemyID]
		
		for eliteType in eliteVariants:
			var amount = eliteVariants[eliteType]
			
			for i in range(amount):
				SteamManager.sendEnemy(enemyID, eliteType, target_peer)

	readyQueue.clear()
	
	updateUI()
