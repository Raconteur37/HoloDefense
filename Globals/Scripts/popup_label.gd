extends CanvasLayer


func setPosition(position):
	$"BoxContainer".global_position = position

func killPopup(money : int, xp : int):
	$"BoxContainer/Enemy Popup/Money Label".text = "$" + str(money)
	$"BoxContainer/Enemy Popup/Xp Label".text = str(xp) + " XP"
	$AnimationPlayer.play("KillPopup")

func insufficientFundsPopup():
	$AnimationPlayer.play("Insufficient Funds")

func damagePopup(damage):
	$"BoxContainer".position.x += randi_range(-10,10)
	$"BoxContainer/Damage Popup".text = str(damage)
	$AnimationPlayer.play("Damage Popup")

func gemPopup(gemName):

	match gemName:

		"Copper":
			$AnimationPlayer.play("GemAnimation")
			$BoxContainer/QuartzGem.visible = false
			$BoxContainer/AmethystGem.visible = false
		"Quartz":
			$AnimationPlayer.play("GemAnimation")
			$BoxContainer/CopperGem.visible = false
			$BoxContainer/AmethystGem.visible = false
		"Amethyst":
			$AnimationPlayer.play("GemAnimation")
			$BoxContainer/CopperGem.visible = false
			$BoxContainer/QuartzGem.visible = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "killPopup":
		queue_free()
	if anim_name == "Insufficient Funds":
		queue_free()
	if anim_name == "Damage Popup":
		queue_free()
	if anim_name == "GemAnimation":
		queue_free()
