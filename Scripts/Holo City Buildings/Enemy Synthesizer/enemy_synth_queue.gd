extends TextureRect

var enemyID : Enemy.EnemyID
var eliteType : Enemy.EliteType

func _ready() -> void:
	#buildCard(Enemy.EnemyID.SPEEDY_TRIANGLE,10,Enemy.EliteType.SUMMONER)
	pass

func buildCard(enemyID,amount,eliteType):
	$TextureRect.texture = EnemyManager._get_enemy_texture(enemyID)
	$RichTextLabel.text = "[color=white][wave amp=10.0 freq=7][font_size=20]X" + str(amount) + "[/font_size][/wave][/color]"
	match eliteType:
		Enemy.EliteType.STEEL:
			self_modulate = Color(0.704, 0.653, 0.695, 1.0)
		Enemy.EliteType.SUMMONER:
			self_modulate = Color(0.782, 0.215, 0.908, 1.0)
		Enemy.EliteType.WINDY:
			self_modulate = Color(0.215, 0.891, 0.908, 1.0)
