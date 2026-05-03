extends Control

@onready var copperSprite = $HBoxContainer/Control/CopperGem
@onready var diamondSprite = $HBoxContainer/Control/DiamondGem
@onready var amethystSprite = $HBoxContainer/Control/AmethystGem
@onready var quartzSprite = $HBoxContainer/Control/QuartzGem
@onready var galactiteSprite = $HBoxContainer/Control/GalactiteGem

@onready var boxContainer = $HBoxContainer

@onready var animationPlayer = $AnimationPlayer

@onready var cityLevelUpLabel = $cityLevelUpLabel
@onready var incomingLabel = $incomingLabel


func setPosition(position):
	self.global_position = position


func gemPopup(gemName):

	match gemName:

		"Copper":
			copperSprite.visible = true
		"Quartz":
			quartzSprite.visible = true
		"Amethyst":
			amethystSprite.visible = true
		"Diamond":
			diamondSprite.visible = true
		"Galactite":
			galactiteSprite.visible = true
		
	animationPlayer.play("GemAnimation")

func cityLevelUp():
	cityLevelUpLabel.show()
	animationPlayer.play("CityLevelUp")

func timeRemainingAlert(time : int):
	incomingLabel.show()
	animationPlayer.play("enemiesWarning")
	if time == 0:
		SoundManager.enemiesIncoming()
		incomingLabel.text = "[pulse color=#FF3131 height=0.5 freq=0.3][font_size=64]Enemies Incoming[/font_size][/pulse]"
	else:
		SoundManager.enemiesIncoming()
		incomingLabel.text = "[pulse color=#0000ff height=0.5 freq=0.3][font_size=64]" + str(time) + " Seconds until enemies arrive[/font_size][/pulse]"


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "GemAnimation":
		queue_free()
	if anim_name == "CityLevelUp":
		queue_free()
