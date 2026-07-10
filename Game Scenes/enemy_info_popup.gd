extends CanvasLayer

@onready var enemyNameLabel = $EnemyInfoPopupBackground/EnemyName
@onready var enemyDescriptionLabel = $EnemyInfoPopupBackground/EnemyDescription
@onready var enemyImage = $EnemyInfoPopupBackground/EnemyRect
@onready var enemyThreatLabel = $EnemyInfoPopupBackground/ThreatLevelLabel
@onready var animPlayer = $AnimationPlayer

@onready var enemyPreview = $SubViewportContainer/SubViewport/EnemyPreview

var canClick = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animPlayer.play("Appear")
	#buildPopup(Enemy.EnemyID.BASIC_SQUARE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		if canClick:
			queue_free()
			get_tree().paused = false

func buildPopup(enemyID : Enemy.EnemyID):
	enemyNameLabel.text = "[pulse color=#c1e5ea  height=0.5 freq=1.5][font_size=25]" + EnemyManager.get_enemy_name(enemyID) + "[/font_size][/pulse]"
	enemyDescriptionLabel.text = str(EnemyManager.get_description(enemyID))
	var threatLevel = EnemyManager.get_threat_level(enemyID)
	match threatLevel:
		"Low":
			enemyThreatLabel.text = "[font_size=25]Threat Level: [pulse color=#41de95   height=0.5 freq=1]" + threatLevel + "[/pulse][/font_size]"
		"Medium":
			enemyThreatLabel.text = "[font_size=25]Threat Level: [pulse color=#f3c220   height=0.5 freq=1]" + threatLevel + "[/pulse][/font_size]"
		"High":
			enemyThreatLabel.text = "[font_size=25]Threat Level: [pulse color=#c4651c  height=0.5 freq=1]" + threatLevel + "[/pulse][/font_size]"
		"Extreme":
			enemyThreatLabel.text = "[font_size=25]Threat Level: [pulse color=#b54131  height=0.5 freq=1]" + threatLevel + "[/pulse][/font_size]"
	enemyPreview.spawnEnemy(enemyID)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Appear":
		get_tree().paused = true
		await get_tree().create_timer(2).timeout
		canClick = true
