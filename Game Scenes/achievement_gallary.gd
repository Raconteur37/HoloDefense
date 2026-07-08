extends CanvasLayer

@onready var template_panel = $AchievementBackground
@onready var hbox_container = $ScrollContainer/HBoxContainer
@onready var scroll_container = $ScrollContainer # Added to easily reference the scroll box

var target_scroll: float = 0.0
var scroll_tween: Tween

func _ready() -> void:
	# Hide the original template so it doesn't just float in the background
	template_panel.hide()
	
	# Clear out any placeholder children inside the HBoxContainer just in case
	for child in hbox_container.get_children():
		child.queue_free()
	
		# --- NEW: Style the Scrollbar via Code ---
	var h_scrollbar = scroll_container.get_h_scroll_bar()
	
	# Create a sleek, modern style for the scrollbar grabber (the part you drag)
	var grabber_style = StyleBoxFlat.new()
	grabber_style.bg_color = Color(0.8, 0.849, 0.5, 1.0) # Soft semi-transparent purple/blue
	grabber_style.corner_radius_top_left = 6
	grabber_style.corner_radius_top_right = 6
	grabber_style.corner_radius_bottom_left = 6
	grabber_style.corner_radius_bottom_right = 6
	
	# Create an invisible background for the scrollbar track
	var track_style = StyleBoxEmpty.new()
	
	# Apply the overrides to the scrollbar
	h_scrollbar.add_theme_stylebox_override("grabber", grabber_style)
	h_scrollbar.add_theme_stylebox_override("grabber_highlight", grabber_style)
	h_scrollbar.add_theme_stylebox_override("grabber_pressed", grabber_style)
	h_scrollbar.add_theme_stylebox_override("scroll", track_style)
	h_scrollbar.add_theme_stylebox_override("scroll_focus", track_style)
	
	populate_achievements()

func populate_achievements() -> void:
	var metadata = AchievementManager.achievement_metadata
	
	for ach_key in metadata.keys():
		var ach_data = metadata[ach_key]
		
		# 1. Duplicate the template panel
		var panel = template_panel.duplicate()
		
		panel.custom_minimum_size = template_panel.size
		# ---------------
		
		var title_node = panel.get_node("AchievementTitle")
		var desc_node = panel.get_node("AchievementDesc")
		var reward_icon = panel.get_node("TextureRect")
		
		title_node.text = "[pulse color=#c53a9d  height=0.5 freq=0.5][font_size=25] " + ach_data.get("title", "Unknown Achievement") + "[/font_size][/pulse]"
		desc_node.text = ach_data.get("description", "No description provided.")
		
		# Load the icon texture
		var icon_path = ach_data.get("icon_path", "")
		if icon_path != "" and ResourceLoader.exists(icon_path):
			reward_icon.texture = load(icon_path)
			
		# 4. Check if the player has actually unlocked it yet!
		var is_unlocked = AchievementManager.is_unlocked(ach_key)
		
		if not is_unlocked:
			panel.material = null
		#	# Dim the whole panel and add a locked prefix
			panel.modulate = Color(0.5, 0.5, 0.5, 0.97) # Grays out the panel
		#	title_node.text = "??? (Locked)"
			# Optional: Hide the reward icon if they haven't earned it yet
			# reward_icon.texture = load("res://Textures/UI/locked_icon.png")
		#else:
		#	panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
			
		# 5. Make the new panel visible and push it into the horizontal scroll box
		panel.show()
		hbox_container.add_child(panel)

func _on_turret_info_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Game Scenes/Main Menu.tscn")

func _input(event: InputEvent) -> void:
	# Only smooth scroll if the mouse is actually hovering over the scroll area
	if not scroll_container.get_global_rect().has_point(get_viewport().get_mouse_position()):
		return
		
	if event is InputEventMouseButton and event.is_pressed():
		# Adjust this number to make the scroll faster or slower per click
		var scroll_step = 350 
		
		# If the scroll has stopped, sync our target back to where we currently are
		if not scroll_tween or not scroll_tween.is_running():
			target_scroll = scroll_container.scroll_horizontal
			
		# Check for mouse wheel scrolling (Godot maps both UP/DOWN and LEFT/RIGHT for horizontal lists)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_LEFT:
			target_scroll -= scroll_step
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_RIGHT:
			target_scroll += scroll_step
		else:
			return # Not a wheel event, exit early
			
		# Grab the hidden scrollbar to find the absolute maximum we are allowed to scroll
		var h_scrollbar = scroll_container.get_h_scroll_bar()
		var max_scroll = h_scrollbar.max_value - h_scrollbar.page
		
		# Prevent scrolling past the beginning or the end
		target_scroll = clamp(target_scroll, 0, max_scroll)
		
		# Kill the old animation if we are rapidly spinning the mouse wheel
		if scroll_tween and scroll_tween.is_running():
			scroll_tween.kill()
			
		# Create a buttery smooth animation to the new scroll position
		scroll_tween = create_tween()
		scroll_tween.tween_property(scroll_container, "scroll_horizontal", target_scroll, 0.25)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
			
		# Tell Godot "I handled this input!", blocking the default jumpy scroll
		get_viewport().set_input_as_handled()
