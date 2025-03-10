extends Control

func _on_timer_timeout() -> void:
	$".".position.y -= 1

func killPopup(money : int, xp : int):
	$"Enemy Popup/Money Label".text = "$" + str(money)
	$"Enemy Popup/Xp Label".text = str(xp) + " XP"
	$AnimationPlayer.play("KillPopup")
	
func insufficientFundsPopup():
	$AnimationPlayer.play("Insufficient Funds")
	
func damagePopup(damage):
	$".".position.x += randi_range(-10,10)
	$"Damage Popup".text = str(damage)
	$AnimationPlayer.play("Damage Popup")

func gemPopup(gemName):
	
	match gemName:
		
		"Copper":
			$AnimationPlayer.play("GemAnimation")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "killPopup":
		queue_free()
	if anim_name == "Insufficient Funds":
		queue_free()
	if anim_name == "Damage Popup":
		queue_free()
	if anim_name == "GemAnimation":
		queue_free()
