extends Control

const SHOP_CONFIG_PATH := "res://Config/Shop.json"
var config: Dictionary = {}

@export var slot_1: TextureRect
@export var slot_2: TextureRect
@export var slot_3: TextureRect

var is_rolling: bool = false 

func _ready() -> void:
	load_shop_config()
	randomize()

# ---------------- Action Methods ----------------

func pull_lever() -> void:
	# 1. Prevent spam clicking
	if is_rolling:
		return 
		
	# 2. Try to spend the stardust
	if not EconomyManager.spend_stardust(config["roll_cost"]):
		print("SlotMachine: Not enough stardust to roll!")
		return
	
	print("SlotMachine: Rolling...")
	EconomyManager.save_economy()
	$"..".updateLabels()
	is_rolling = true # Lock the machine
	
	# 3. Calculate the math in the background instantly
	var rolled_rarity = _get_random_rarity()
	var won_turret_id = -1
	
	if rolled_rarity != "nothing":
		won_turret_id = _get_turret_from_manager(rolled_rarity)
		
	# 4. Run the visual spin animation! 
	# The code will pause here and wait for the animation to finish
	await animate_spin(won_turret_id)
	
	# 5. Process the results AFTER the spin finishes
	if rolled_rarity == "nothing":
		print("SlotMachine: Rolled nothing. Better luck next time!")
	elif won_turret_id == -1:
		print("SlotMachine: Rolled %s, but all %s turrets are already unlocked!" % [rolled_rarity, rolled_rarity])
		print("SlotMachine: Refunding %d stardust." % config["roll_cost"])
		EconomyManager.add_stardust(config["roll_cost"])
	else:
		EconomyManager.unlock_turret(won_turret_id)
		var turret_name = TurretManager.get_turret_string(won_turret_id)
		print("SlotMachine: JACKPOT! Unlocked ", turret_name)
		
	# Unlock the machine for the next roll
	is_rolling = false


# ---------------- Animation Methods ----------------

func animate_spin(final_turret_id: int) -> void:
	var total_spins = 100 # How many times the textures swap
	var spin_delay = 0.05 # Starts fast (0.05 seconds between swaps)
	
	# Loop to create the rapid spinning effect
	for i in range(total_spins):
		# Assign a completely random texture to each slot
		slot_1.texture = _get_random_texture()
		slot_2.texture = _get_random_texture()
		slot_3.texture = _get_random_texture()
		
		# Wait for 'spin_delay' seconds before continuing the loop
		await get_tree().create_timer(spin_delay).timeout
		
		# Gradually increase the delay to make it look like the wheels are slowing down
		spin_delay += 0.01 
		
	# The spin has stopped! Now set the final textures.
	if final_turret_id != -1:
		# It's a WIN! Make all three slots match the won turret
		var win_texture = TurretManager.getTurretTexture(final_turret_id)
		slot_1.texture = win_texture
		slot_2.texture = win_texture
		slot_3.texture = win_texture
		
		# Optional: Add a little "pop" effect when they win
		_pop_animation(slot_1)
		_pop_animation(slot_2)
		_pop_animation(slot_3)
	else:
		# It's a LOSS (or refund). Ensure the slots don't accidentally match!
		slot_1.texture = _get_random_texture()
		slot_2.texture = _get_random_texture()
		
		# Keep picking a random texture for slot 3 until it's different from slot 1
		var lose_tex_3 = _get_random_texture()
		while lose_tex_3 == slot_1.texture:
			lose_tex_3 = _get_random_texture()
			
		slot_3.texture = lose_tex_3


func _get_random_texture() -> Texture2D:
	# Grabs a random ID from the master list in TurretManager
	var random_id = TurretManager.ALL_TURRETS.pick_random()
	return TurretManager.getTurretTexture(random_id)


# A little juice to make the winning turrets bounce when they lock in
func _pop_animation(target_node: Control) -> void:
	# Ensure the pivot is in the center for a nice scaling effect
	target_node.pivot_offset = target_node.size / 2.0 
	
	var tween = create_tween()
	# Scale up slightly
	tween.tween_property(target_node, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_SINE)
	# Scale back to normal
	tween.tween_property(target_node, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BOUNCE)

# ---------------- Configuration & Logic Helpers ----------------
# (Keep load_shop_config, _get_random_rarity, and _get_turret_from_manager exactly the same as the previous response)

func load_shop_config() -> void:
	# ... [Same code as previous step] ...
	var default_config: Dictionary = {
		"roll_cost": 10,
		"rarity_weights": {
			"nothing": 0.90, "common": 0.05, "rare": 0.02,
			"super_rare": 0.01, "legendary": 0.005, "unseen": 0.0001
		}
	}
	if FileAccess.file_exists(SHOP_CONFIG_PATH):
		var file := FileAccess.open(SHOP_CONFIG_PATH, FileAccess.READ)
		if file:
			var json_str := file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(json_str)
			if typeof(parsed) == TYPE_DICTIONARY:
				config = parsed
				return
	config = default_config

func _get_random_rarity() -> String:
	# ... [Same code as previous step] ...
	var weights = config["rarity_weights"]
	var total_weight: float = 0.0
	for rarity in weights: total_weight += float(weights[rarity])
	var random_roll = randf() * total_weight
	var cumulative_weight: float = 0.0
	for rarity in weights:
		cumulative_weight += float(weights[rarity])
		if random_roll <= cumulative_weight: return rarity
	return "nothing" 

func _get_turret_from_manager(rarity: String) -> int:
	# ... [Same code as previous step] ...
	var pool: Array = []
	match rarity:
		"common": pool = TurretManager.lockedCommonTurrets
		"rare": pool = TurretManager.lockedRareTurrets
		"super_rare": pool = TurretManager.lockedSuperRareTurrets
		"legendary": pool = TurretManager.lockedLegendaryTurrets
		"unseen": pool = TurretManager.lockedUnseenTurrets
	if pool.is_empty(): return -1
	return pool.pick_random()


func _on_button_pressed() -> void:
	pull_lever()
