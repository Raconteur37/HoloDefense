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

var placeTurretIconScene = preload("res://Game Scenes/PlaceTurretIcon.tscn")

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
	pass


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

func refreshTurretUI(turret : Turret):
	var properties : Array = TurretManager.createPropertiesLabels(turret)
	for label in properties:
		turretStatsGrid.add_child(label)
	updateHealth(turret)
	turretImage.texture = TurretManager.getTurretTexture(turret.turretID)
	turretNameLabel.text = str(turret.name) + "\n Lvl: " + str(turret.level) + " Tier: " + str(turret.upgradeTier)
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
