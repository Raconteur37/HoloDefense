extends Control

const SHOP_CONFIG_PATH := "res://Config/Shop.json"
var config: Dictionary = {}

@export var slot_1: TextureRect
@export var slot_2: TextureRect
@export var slot_3: TextureRect

@onready var winLabel = $"../winLabel"

var is_rolling: bool = false 

func _ready() -> void:
	load_shop_config()
	randomize()
	
	var locked_pool: Array = []
	locked_pool.append_array(TurretManager.lockedCommonTurrets)
	locked_pool.append_array(TurretManager.lockedRareTurrets)
	locked_pool.append_array(TurretManager.lockedSuperRareTurrets)
	locked_pool.append_array(TurretManager.lockedLegendaryTurrets)
	locked_pool.append_array(TurretManager.lockedUnseenTurrets)

	if locked_pool.size() <= 1:
		$TextureButton.hide()
		$Label.text = "You unlocked all the turrets!"
		$TextureRect.hide()

# ---------------- Action Methods ----------------

func pull_lever() -> void:
	# 1. Prevent spam clicking
	if is_rolling:
		return 
		
	# 2. Try to spend the stardust
	if not EconomyManager.spend_stardust(config["roll_cost"]):
		#print("SlotMachine: Not enough stardust to roll!")
		return
	
	#print("SlotMachine: Rolling...")
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
		winLabel.show()
		var display_name = TurretManager.get_turret_string(won_turret_id).capitalize()
		winLabel.text = "[center][font_size=150][b][rainbow freq=10.0 sat=1.0 val=1.0]YOU WON %s![/rainbow][/b][/font_size][/center]" % display_name
		_spawn_jackpot_particles(won_turret_id)

		await _play_jackpot_celebration()
		
	# Unlock the machine for the next roll
	is_rolling = false
	winLabel.hide()


# ---------------- Animation Methods ----------------

func _play_jackpot_celebration() -> void:
	# ---> PLAY YOUR JACKPOT SOUND HERE <---
	SoundManager.playJackPotSound()
	
	var total_jumps = 20    
	var jump_height = 40.0  
	var up_time = 0.1      
	var down_time = 0.2     
	var stagger = 0.10    
	
	# IMPORTANT: Store the absolute starting positions to guarantee they return home!
	var base_y1 = slot_1.position.y
	var base_y2 = slot_2.position.y
	var base_y3 = slot_3.position.y
	
	# --- SLOT 1 TWEEN ---
	var t1 = create_tween().set_loops(total_jumps)
	t1.tween_property(slot_1, "position:y", base_y1 - jump_height, up_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t1.tween_property(slot_1, "position:y", base_y1, down_time).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Wait a split second to create the "wave" delay
	await get_tree().create_timer(stagger).timeout
	
	# --- SLOT 2 TWEEN ---
	var t2 = create_tween().set_loops(total_jumps)
	t2.tween_property(slot_2, "position:y", base_y2 - jump_height, up_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t2.tween_property(slot_2, "position:y", base_y2, down_time).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Wait another split second for the 3rd slot
	await get_tree().create_timer(stagger).timeout
	
	# --- SLOT 3 TWEEN ---
	var t3 = create_tween().set_loops(total_jumps)
	t3.tween_property(slot_3, "position:y", base_y3 - jump_height, up_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t3.tween_property(slot_3, "position:y", base_y3, down_time).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Pauses the slot machine script until the very last tween (Slot 3) finishes all 10 of its jumps
	await t3.finished
	
	# The final Lockout Timer before the player is allowed to roll again
	await get_tree().create_timer(1.0).timeout

func animate_spin(final_turret_id: int) -> void:

	var final_tex_1: Texture2D
	var final_tex_2: Texture2D
	var final_tex_3: Texture2D
	
	if final_turret_id != -1:
		var win_tex = TurretManager.getTurretTexture(final_turret_id)
		final_tex_1 = win_tex
		final_tex_2 = win_tex
		final_tex_3 = win_tex
	else:
		final_tex_1 = _get_random_texture()
		final_tex_2 = _get_random_texture()
		final_tex_3 = _get_random_texture()
		
		while final_tex_1 == final_tex_2 and final_tex_2 == final_tex_3:
			final_tex_3 = _get_random_texture()

	# --- NEW LOGIC: Check if the first two match ---
	var has_tease = (final_tex_1 == final_tex_2)

	var stop_1 = 15 # Slot 1 locks first
	var stop_2 = 35 # Slot 2 locks a bit later
	
	# If they match, keep the dramatic 45. Otherwise, end it quickly at 38.
	var stop_3 = 45 if has_tease else 38 
	
	var spin_delay = 0.04 # Starting speed (very fast)
	
	# 3. Run the spinning loop
	for current_spin in range(stop_3):
		
		SoundManager.playSlotTick()
		
		if current_spin < stop_1:
			slot_1.texture = _get_random_texture(slot_1.texture) 
		elif current_spin == stop_1:
			slot_1.texture = final_tex_1
			_pop_animation(slot_1) 
			SoundManager.playSlotSelect()
			
		# --- Reel 2 ---
		if current_spin < stop_2:
			slot_2.texture = _get_random_texture(slot_2.texture) 
		elif current_spin == stop_2:
			slot_2.texture = final_tex_2
			_pop_animation(slot_2)
			SoundManager.playSlotSelect()
			
		# --- Reel 3 ---
		if current_spin < stop_3 - 1:
			slot_3.texture = _get_random_texture(slot_3.texture) 
			
		# Wait before the next cycle
		await get_tree().create_timer(spin_delay).timeout
		
		# 4. Apply dynamic friction (slowdown)
		if current_spin < stop_1:
			spin_delay += 0.002 
		elif current_spin < stop_2:
			spin_delay += 0.005 
		else:
			# --- NEW LOGIC: Only apply dramatic friction if it's a tease ---
			if has_tease:
				spin_delay += 0.02 
			else:
				spin_delay += 0.005 # Keep it rolling fast since it's a guaranteed loss
				
	# 5. Lock in the final slot
	slot_3.texture = final_tex_3
	_pop_animation(slot_3)
	SoundManager.playSlotSelect()
	
	await get_tree().create_timer(0.5).timeout

func _get_random_texture(current_texture: Texture2D = null) -> Texture2D:

	var locked_pool: Array = []
	locked_pool.append_array(TurretManager.lockedCommonTurrets)
	locked_pool.append_array(TurretManager.lockedRareTurrets)
	locked_pool.append_array(TurretManager.lockedSuperRareTurrets)
	locked_pool.append_array(TurretManager.lockedLegendaryTurrets)
	locked_pool.append_array(TurretManager.lockedUnseenTurrets)
	

	if locked_pool.is_empty():
		locked_pool = TurretManager.ALL_TURRETS
	
	var random_id = locked_pool.pick_random()
	var new_texture = TurretManager.getTurretTexture(random_id)
	
	
	var attempts = 0
	while new_texture == current_texture and attempts < 10:
		random_id = locked_pool.pick_random()
		new_texture = TurretManager.getTurretTexture(random_id)
		attempts += 1
		
	return new_texture


func _pop_animation(target_node: Control) -> void:
	target_node.pivot_offset = target_node.size / 2.0 
	
	var tween = create_tween()
	tween.tween_property(target_node, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_property(target_node, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BOUNCE)

# ---------------- Configuration & Logic Helpers ----------------

func load_shop_config() -> void:
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
				$"..".shopConfig = config
				return
	config = default_config

func _get_random_rarity() -> String:
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
	var pool: Array = []
	match rarity:
		"common": pool = TurretManager.lockedCommonTurrets
		"rare": pool = TurretManager.lockedRareTurrets
		"super_rare": pool = TurretManager.lockedSuperRareTurrets
		"legendary": pool = TurretManager.lockedLegendaryTurrets
		"unseen": pool = TurretManager.lockedUnseenTurrets
	if pool.is_empty(): return -1
	return pool.pick_random()

func _spawn_jackpot_particles(turret_id: int) -> void:
	var tex = TurretManager.getTurretTexture(turret_id)
	var screen_size = get_viewport().get_visible_rect().size 
	
	# Calculate the exact center of the screen
	var center_pos = screen_size / 2.0 
	
	var waves = 40 # How many times it pops
	var particles_per_wave = 40 # How many particles in each pop

	for wave in range(waves):
		for i in range(particles_per_wave):
			var p = TextureRect.new()
			p.texture = tex
			p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			
			var p_size = randf_range(20.0, 50.0)
			p.size = Vector2(p_size, p_size)
			p.pivot_offset = p.size / 2.0
			p.z_index = 100 
			
			# ---> THE FIX: Break free from the parent's coordinate offset! <---
			p.top_level = true 

			var start_pos = center_pos + Vector2(randf_range(-15, 15), randf_range(-15, 15))
			p.position = start_pos - (p.size / 2.0)

			var colors = [Color.GOLD, Color.CYAN, Color.MAGENTA, Color.LIME_GREEN, Color.WHITE]
			p.modulate = colors.pick_random()

			add_child(p)

			var angle = randf_range(0, TAU)
			var distance = randf_range(200.0, 800.0) 
			var end_pos = p.position + (Vector2(cos(angle), sin(angle)) * distance)

			var anim_time = randf_range(1.0, 2.5)
			
			var t = create_tween().set_parallel(true)
			t.tween_property(p, "position", end_pos, anim_time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			t.tween_property(p, "rotation", randf_range(-TAU*3, TAU*3), anim_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			t.tween_property(p, "scale", Vector2.ZERO, anim_time / 2.0).set_delay(anim_time / 2.0)

			t.chain().tween_callback(p.queue_free)
			
		await get_tree().create_timer(0.1).timeout

func _on_button_pressed() -> void:
	pull_lever()

func _on_texture_button_pressed() -> void:
	pull_lever()
