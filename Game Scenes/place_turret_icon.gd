extends Control

var turretID = null
var amountLabel : Label
var button : TextureButton



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	amountLabel = $AmountLabel
	button = $DisplayButton
	GameManager.turretStorageChanged.connect(refreshUI)
	setTurret(Turret.TurretID.ARROW_TURRET)

func refreshUI():
	var amount = GameManager.getTurretAmount(turretID)
	if amount <= 0:
		queue_free()
	else:
		amountLabel.text = "x" + str(amount)

func setTurret(aturret):
	turretID = aturret
	
	button.texture_normal = TurretManager.getTurretTexture(turretID)
	
	amountLabel.text = "x" + str(GameManager.getTurretAmount(turretID))


func _on_display_button_pressed() -> void:
	if turretID != null:
		PlacementManager.begin_placement(turretID)
