extends CPUParticles2D

func setPosition(aposition):
	position = aposition
	position.y += 3

func setTexture(item : Item.theItem):
	match item:
		
		Item.theItem.COMMON_SCRAP:
			texture = load("res://Textures/Citizens/Scrap/Common Scrap.png")
		Item.theItem.RARE_SCRAP:
			texture = load("res://Textures/Citizens/Scrap/Rare Scrap.png")
		Item.theItem.SUPER_RARE_SCRAP:
			texture = load("res://Textures/Citizens/Scrap/Super Rare Scrap.png")
		Item.theItem.LEGENDARY_SCRAP:
			texture = load("res://Textures/Citizens/Scrap/Legendary Scrap.png")
		Item.theItem.UNSEEN_SCRAP:
			texture = load("res://Textures/Citizens/Scrap/Unseen Scrap.png")


func _on_finished() -> void:
	queue_free()
