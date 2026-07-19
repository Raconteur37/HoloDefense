extends CPUParticles2D

func setPosition(aposition):
	position = aposition
	position.y += 3

func setTexture(item : Item.theItem):
	match item:
		
		Item.theItem.COMMON_SCRAP:
			texture = load("res://Textures/Citizens/Scrap/small_scrap0.png")
		Item.theItem.RARE_SCRAP:
			texture = load("res://Textures/Citizens/Scrap/small_scrap2.png")
		Item.theItem.SUPER_RARE_SCRAP:
			texture = load("res://Textures/Citizens/Scrap/small_scrap4.png")
		Item.theItem.LEGENDARY_SCRAP:
			texture = load("res://Textures/Citizens/Scrap/small_scrap1.png")
		Item.theItem.UNSEEN_SCRAP:
			texture = load("res://Textures/Citizens/Scrap/small_scrap3.png")


func _on_finished() -> void:
	queue_free()
