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
	XPBar = $"CanvasLayer/PanelContainer3/MarginContainer/XP Bar"
	upgradeTurrentOneButton = $CanvasLayer/PanelContainer/MarginContainer/GridContainer/TurretOneMarginContainer/PanelContainer/UpgradeOneButton
	waveLabel = $CanvasLayer/PanelContainer2/MarginContainer/GridContainer/MarginContainer4/Label
	breakTimer = $BreakTimer
	GameManager.beacon = beacon
	beacon.global_position = Vector2(1920 / 2, 1080 / 2)
	
	breakTimer.start()
	
	
	
	
func _process(delta: float) -> void:
	
	moneyLabel.text = "$" +  str(GameManager.getCurrentMoney())
	waveLabel.text = str(GameManager.currentWave)
	
	if GameManager.enemiesAlive.size() <= 0 and GameManager.summonDict.size() <= 0 and GameManager.inWave:
		breakTimer.start()
		GameManager.inWave = false
	
	if (GameManager.getUpgradeTokens() > 0):
		upgradeTurrentOneButton.disabled = false
		upgradeTurrentOneButton.show()
	else:
		upgradeTurrentOneButton.disabled = true
		upgradeTurrentOneButton.hide()

func fullXpBar():
	XPBar.value = 0
	GameManager.inGamePlayerLevel
	GameManager.onInGameLevelUp($"CanvasLayer/PanelContainer3/MarginContainer/XP Bar")


func _on_xp_bar_value_changed(value: float) -> void:
	if (XPBar.value >= XPBar.max_value):
		fullXpBar()


func _on_break_timer_timeout() -> void:
	if not GameManager.inWave:
		GameManager.startWave()
