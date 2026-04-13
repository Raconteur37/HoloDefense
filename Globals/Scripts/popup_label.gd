extends Control

@onready var copperSprite = $HBoxContainer/Control/CopperGem
@onready var diamondSprite = $HBoxContainer/Control/DiamondGem
@onready var amethystSprite = $HBoxContainer/Control/AmethystGem
@onready var quartzSprite = $HBoxContainer/Control/QuartzGem

@onready var boxContainer = $HBoxContainer

@onready var animationPlayer = $AnimationPlayer


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
		
	animationPlayer.play("GemAnimation")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "GemAnimation":
		queue_free()
