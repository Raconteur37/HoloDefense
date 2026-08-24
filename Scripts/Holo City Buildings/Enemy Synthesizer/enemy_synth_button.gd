extends TextureRect

var buttonID
var baseCost
var cost

func buildButton(enemyID : Enemy.EnemyID):
	$TextureRect.texture = EnemyManager._get_enemy_texture(enemyID)
	$RichTextLabel.text = "[img=14x14]res://Textures/Citizens/Scrap/Common Scrap.png[/img]" + str(EnemyManager.get_enemy_cost(enemyID))
	buttonID = enemyID
	baseCost = EnemyManager.get_enemy_cost(buttonID)
	cost = baseCost

func _on_texture_button_pressed() -> void:
	var node = find_parent("EnemySynthesizer")
	if node != null:
		node.attemptBuy(buttonID,cost)

func updatePrice(mult):
	cost = int(baseCost * mult)
	$RichTextLabel.text = "[img=14x14]res://Textures/Citizens/Scrap/Common Scrap.png[/img]" + str(cost)

func resetPrice():
	$RichTextLabel.text = "[img=14x14]res://Textures/Citizens/Scrap/Common Scrap.png[/img]" + str(baseCost)
