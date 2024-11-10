extends GridContainer


func _on_timer_timeout() -> void:
	$".".position.y -= 1 

func killPopup(money : int, xp : int):
	$"Money Label".text = "$" + str(money)
	$"Xp Label".text = str(xp) + " XP"
	$AnimationPlayer.play("KillPopup")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "killPopup":
		queue_free()
