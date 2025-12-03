extends Node2D

var beacon
var XPBar
var moneyLabel
var waveLabel
var breakTimer

var maxXp : bool = false

var upgradeTurrentOneButton

func _ready() -> void:


	beacon = $CanvasLayer/Beacon
	moneyLabel = $CanvasLayer/PanelContainer2/MarginContainer/GridContainer/MarginContainer2/MoneyLabel
	XPBar = $"CanvasLayer/Bottom UI Control/XP Bar"
	upgradeTurrentOneButton = $CanvasLayer/PanelContainer/MarginContainer/GridContainer/TurretOneMarginContainer/PanelContainer/UpgradeOneButton
	waveLabel = $CanvasLayer/PanelContainer2/MarginContainer/GridContainer/MarginContainer4/Label
	breakTimer = $BreakTimer
	GameManager.beacon = beacon

	PlacementManager.inGame = true

	breakTimer.start()




func _process(delta: float) -> void:

	moneyLabel.text = "$" +  str(GameManager.getCurrentMoney())
	waveLabel.text = str(GameManager.currentWave)

	if GameManager.enemiesAlive.size() <= 0 and GameManager.summonDict.size() <= 0 and GameManager.inWave:
		breakTimer.start()
		GameManager.inWave = false


func fullXpBar():
	XPBar.value = 0
	GameManager.onInGameLevelUp(XPBar)


func _on_xp_bar_value_changed(value: float) -> void:
	if (XPBar.value >= XPBar.max_value):
		fullXpBar()


func _on_break_timer_timeout() -> void:
	if not GameManager.inWave:
		GameManager.startWave()
