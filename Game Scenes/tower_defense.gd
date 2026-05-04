extends CanvasLayer

var enableHover
var disableHover

var turretDataUI

var turretImage
var turretNameLabel
var turretStatsGrid

var healthBar
var healthRichLabelText

var bottomUI

var turretsAvailableGrid

@onready var turretLabel = preload("res://Labels/turret_info_label.tres")

@onready var systemLabel = $BottomUI/WaveData/SystemLabel
@onready var waveLabel = $BottomUI/WaveData/WaveLabel
@onready var intermissionLabel = $BottomUI/WaveData/IntermissionLabel
@onready var placeHolderTimer = $Timer

var placeTurretIconScene = preload("res://Game Scenes/PlaceTurretIcon.tscn")

var alert30Sec = false
var alert10Sec = false
var alertEnemiesIncoming = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enableHover = $HoverControl/Enable
	disableHover = $HoverControl/Disable
	bottomUI = $BottomUI
	turretsAvailableGrid = $BottomUI/TurretsAvailableGrid
	turretDataUI = $BottomUI/TurretData
	turretNameLabel = $BottomUI/TurretData/NameLevelLabel
	turretImage = $BottomUI/TurretData/Turretimage
	turretStatsGrid = $BottomUI/TurretData/TurretStatsGridContainer
	healthBar = $"BottomUI/TurretData/Health Bar"
	healthRichLabelText = $BottomUI/TurretData/RichTextLabel
	

	
	GameManager.turretStorageChanged.connect(refreshUI)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not placeHolderTimer.is_stopped():
		var time = placeHolderTimer.time_left
		var mins = int(time) / 60
		var secs = fmod(time, 60)
		
		# %02d: 2 digits, padded with a zero (e.g., 01)
		# %05.2f: 5 total spaces (00.00), padded with a zero, 2 decimal places
		intermissionLabel.text = "Intermission Time: %02d:%05.2f" % [mins, secs]

		if time <= 30 and not alert30Sec:
			PopupManager.enemiesIncomingPopup(time)
			alert30Sec = true
			alertEnemiesIncoming = false
		if time <= 10 and not alert10Sec:
			PopupManager.enemiesIncomingPopup(time)
			alert10Sec = true
			
			
	if placeHolderTimer.is_stopped():
		if not alertEnemiesIncoming:
			PopupManager.enemiesIncomingPopup(0)
			alertEnemiesIncoming = true
		alert30Sec = false
		alert10Sec = false


func _on_enable_mouse_entered() -> void:
	bottomUI.show()
	buildBottomUI()
	await get_tree().create_timer(.3).timeout
	disableHover.show()
	enableHover.hide()



func _on_disable_mouse_entered() -> void:
	bottomUI.hide()
	await get_tree().create_timer(.3).timeout
	enableHover.show()
	disableHover.hide()

func refreshUI():
	for child in turretsAvailableGrid.get_children():
		child.queue_free()
	for turret in GameManager.turretStorage:
		var icon = placeTurretIconScene.instantiate()
		turretsAvailableGrid.add_child(icon)
		icon.setTurret(turret)

func refreshWaveInfo(time):
	if placeHolderTimer != null:
		if placeHolderTimer.is_stopped() and time > 0:
			placeHolderTimer.wait_time = time
			placeHolderTimer.start()
		systemLabel.text = "System: " + str(WaveManager.systemNumber) + "/5"
		waveLabel.text = "Current Wave: " + str(WaveManager.currentWave)
		intermissionLabel.text = ""

func refreshTurretUI(turret : Turret):
	for child in turretStatsGrid.get_children():
		child.queue_free()
	var properties : Array = TurretManager.createPropertiesLabels(turret)
	for label in properties:
		turretStatsGrid.add_child(label)
	updateHealth(turret)
	turretImage.texture = TurretManager.getTurretTexture(turret.turretID)
	turretNameLabel.text = str(turret.turretName) + "\n Lvl: " + str(turret.level) + " Tier: " + str(turret.upgradeTier)
	turretDataUI.show()
	
func removeTurretUI():
	for child in turretStatsGrid.get_children():
		child.queue_free()
	turretDataUI.hide()
	
func buildBottomUI():
	for child in turretsAvailableGrid.get_children():
		child.queue_free()
	for turret in GameManager.turretStorage:
		var icon = placeTurretIconScene.instantiate()
		turretsAvailableGrid.add_child(icon)
		icon.setTurret(turret)

func updateHealth(turret):
	if turret.get("health") != null:
		healthBar.max_value = turret.maxHealth
		healthBar.value = turret.health
		healthRichLabelText.text = "[img=32x32]res://Textures/Icons/Health Icon.png[/img]     " + str(turret.health) + "/" + str(turret.maxHealth)
		healthBar.tint_progress = Color.DEEP_PINK
	if turret.get("armor") != null:
		if turret.armor > 0:
			healthRichLabelText.text = "[img=32x32]res://Textures/Icons/Shield Icon.png[/img]          " + str(turret.armor)
			healthBar.max_value = turret.armor
			healthBar.value = turret.armor
			healthBar.tint_progress = Color.DARK_GRAY
