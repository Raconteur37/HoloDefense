extends CanvasLayer

@onready var timer = $Control/Timer
@onready var animPlayer = $AnimationPlayer

@onready var achievementLabel = $Control/AchievementTitle
@onready var rewardPhoto = $Control/Reward
@onready var descriptionLabel = $Control/DescriptionLabel

@onready var textureProgressBar = $Control/TextureProgressBar

#TODO make it glow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#buildAchievementBar("Balls","balls","res://Textures/Turrets/Arrow Turret/ArrowTurret.png",4)
	SoundManager.playAchievementSound()
	animPlayer.play("FadeIn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not timer.is_stopped():
		var time_ratio = timer.time_left / timer.wait_time
		textureProgressBar.value = time_ratio * 100

func buildAchievementBar(achievementTitle : String,achievementDescription : String,rewardIcon,time):
	achievementLabel.text = "[pulse color=aqua height=0.5 freq=0.5][font_size=30]" + achievementTitle + "[/font_size][/pulse]"
	descriptionLabel.text = achievementDescription
	rewardPhoto.texture = load(rewardIcon)
	timer.wait_time = time
	timer.start()

func _on_timer_timeout() -> void:
	animPlayer.play("FadeOut")
