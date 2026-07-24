extends Control

# FOR THOSE OF YOU SIFTING THROUGH MY CODE JUST KNOW THAT IM AWARE HOW
# MUCH THIS SUCKS BUT ITS FINE CUS IM NOT WORKING WITH ANYONE SO YEAH

var stage = 4
var stageActive = false

var inputActive = false

var currentPopup

@onready var skipButtonContainer = $SkipButtonContainer
@onready var commanderPopup = preload("res://Game Scenes/CommanderPopup.tscn")
@onready var cityCanvas = $CityCanvas
@onready var animationPlayer = $AnimationPlayer
@onready var startingCitizen : Citizen = cityCanvas.find_child("StartingCitizen")
@onready var gemScraper = cityCanvas.find_child("GemScraper")
@onready var materialAtomizer = cityCanvas.find_child("MaterialAtomizer")
@onready var fabricator = cityCanvas.find_child("Fabricator")
@onready var researchLab = cityCanvas.find_child("ResearchLab")
@onready var towerDefenseScene = $TowerDefenseCanvas
@onready var arrow = $CanvasLayer2/Arrow

var secondCit

func _ready() -> void:
	cityCanvas.process_mode = Node.PROCESS_MODE_DISABLED
	skipButtonContainer.hide()
	startingCitizen.tutorial = true

func _input(event: InputEvent) -> void:
	
	if stage == 49:
		if event is InputEventKey and event.keycode == KEY_SPACE and event.is_pressed():
			stageActive = false
			stage += 1
		else:
			return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and inputActive:
		
		if stage == 14:
			return
		if stage == 16:
			return
		if stage == 23:
			return
		if stage == 24:
			return
		if stage == 27:
			return
		if stage == 28:
			return
		if stage == 30:
			return
		if stage == 31:
			return
		if stage == 32:
			return
		if stage == 34:
			return
		if stage == 36:
			return
		if stage == 37:
			return
		if stage == 44:
			return
		if stage == 11:
			return
				
		else:
			stageActive = false
			stage += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stage == 11:
		if startingCitizen.selected: 
			stageActive = false
			stage += 1
	if stage == 44:
		if GameManager.turretsPlaced.size() >= 1:
			stageActive = false
			stage += 1
	if stage == 37:
		if researchLab.currentSlots >= 1:
			stageActive = false
			stage += 1
	if stage == 36:
		if researchLab.menu.visible:
			stageActive = false
			stage += 1
	if stage == 34:
		if fabricator.specificTargetPopup.visible:
			stageActive = false
			stage += 1
	if stage == 33:
		fabricator.menu.show()
	if stage == 32:
		if fabricator.assignedAutoBuildList[0] != null:
			stageActive = false
			stage += 1
	if stage == 31:
		if fabricator.assignedWorkers[0] != null:
			stageActive = false
			stage += 1
	if stage == 30:
		if secondCit != null:
			if secondCit.currentJob == Citizen.Job.FABRICATOR:
				stageActive = false
				stage += 1
		if startingCitizen != null:
			if startingCitizen.currentJob == Citizen.Job.FABRICATOR:
				stageActive = false
				stage += 1
	if stage == 28:
		if GameManager.turretStorage.size() >= 1:
			stageActive = false
			stage += 1
	if stage == 27:
		if fabricator.menu.visible:
			stageActive = false
			stage += 1
	if stage == 23:
		for child in cityCanvas.get_children():
			if child is CharacterBody2D:
				if child != startingCitizen:
					secondCit = child
					secondCit.tutorial = true
					stageActive = false
					stage += 1
	if stage >= 17 and stage <= 21:
			gemScraper.menu.show()
	if stage == 25 or stage == 26:
			materialAtomizer.atomizerMenu.show()
	if stage == 24:
		if secondCit.currentJob == Citizen.Job.MATERIAL_ATOMIZER:
			stageActive = false
			stage += 1
	if stage == 14:
		if startingCitizen.currentJob == Citizen.Job.GEM_SCRAPER:
			stageActive = false
			stage += 1
	if stage == 16:
		if gemScraper.menu.visible:
			stageActive = false
			stage += 1
			await get_tree().create_timer(0.2).timeout
	if stage == 0 and not stageActive:
		stageActive = true
		activatePopup("Welcome Commander, it's been a while...","speaking")
	if stage == 1 and not stageActive:
		stageActive = true
		activatePopup("You've been offline for eons, but our goal of reaching the edge of the universe hasn't subsided.","speaking")
	if stage == 2 and not stageActive:
		stageActive = true
		activatePopup("Did the systems restore your memory? If not, I can briefly help you remember your task.","speaking")
	if stage == 3 and not stageActive:
		stageActive = true
		activatePopup("Understandable, booting up the simulation now...","happy")
	if stage == 4 and not stageActive:
		stageActive = true
		activatePopup("Welcome to the city! I know it's pretty overwhelming but don't worry, it'll all come back to you.","happy")
		cityCanvas.show()
	if stage == 5 and not stageActive:
		stageActive = true
		fabricator.hide()
		activatePopup("Take a look to my left, you'll see the Generator Level and the City level as well as the resources the generator produces.","speaking")
		#arrow.show()
		arrow.position = Vector2(248,161)
	if stage == 6 and not stageActive:
		fabricator.show()
		stageActive = true
		activatePopup("This is the progress bar for the production, as well as where you can generate citizens and upgrade the generator.","speaking")
		arrow.position = Vector2(372,383)
	if stage == 7 and not stageActive:
		arrow.hide()
		stageActive = true
		activatePopup("Here you can see the current resources you have and the integrity of the city.","speaking")
	if stage == 8 and not stageActive:
		stageActive = true
		activatePopup("You will need to balance Money, Scrap, and Energy, if you mismanage this, the city will fall.","speaking")
	if stage == 9 and not stageActive:
		stageActive = true
		activatePopup("Here is where you can keep track of Citizens and below is a mini map of where enemies are in the System.","speaking")
		#arrow.show()
		#arrow.rotation = 180
		#arrow.position = Vector2(157,733)
	if stage == 10 and not stageActive:
		stageActive = true
		activatePopup("(No, that Citizen isn't me)","speaking")
	if stage == 11 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("You can select the Citizen by clicking on them or their portrait....do so now.","speaking")
	if stage == 12 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("Great, here you can see their name, job proficiency, and their current working progress.","speaking")
	if stage == 13 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_DISABLED
		stageActive = true
		activatePopup("They will become more proficient the more they work the same job.","speaking")
	if stage == 14 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("Speaking of jobs, right click on the Gem Scraper while the worker is selected to assign them to work there.","speaking")
	if stage == 15 and not stageActive:
		stageActive = true
		activatePopup("Great, now the worker is a Gem Scraper and will find gems over time. They will deliver them to storage after finding them automatically.","speaking")
	if stage == 16 and not stageActive:
		stageActive = true
		activatePopup("Now select the Gem Scraper and open its menu.","speaking")
	if stage == 17 and not stageActive:
		stageActive = true
		cityCanvas.process_mode = Node.PROCESS_MODE_DISABLED
		activatePopup("Here you can see the chances of what kind of gem the workers can find as well as the Money and Energy value of each.","speaking")
	if stage == 18 and not stageActive:
		stageActive = true
		activatePopup("You can spend money to upgrade the chances of finding rare gems.","speaking")
	if stage == 19 and not stageActive:
		stageActive = true
		activatePopup("Additionally, you can select the Auto Sell or Auto Convert buttons below the respective gem to do that process when workers deliver that gem.","speaking")
	if stage == 20 and not stageActive:
		stageActive = true
		activatePopup("Gems are the most important resource for consistent income and energy, balance the conversion and selling wisely.","speaking")
	if stage == 21 and not stageActive:
		stageActive = true
		activatePopup("You can manually generate gems in your free time by inputting the sequence given at the bottom of the scraper. (Using WASD or arrows)","speaking")
	if stage == 22 and not stageActive:
		gemScraper.menu.hide()
		stageActive = true
		activatePopup("While that worker is working, let's generate another Citizen and put them to work.","speaking")
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
	if stage == 23 and not stageActive:
		stageActive = true
		activatePopup("Citizens take time to generate and you can see the queue here.","speaking")
	if stage == 24 and not stageActive:
		stageActive = true
		activatePopup("Now we have another citizen, let's assign them to the Material Atomizer here.","speaking")
	if stage == 25 and not stageActive:
		stageActive = true
		activatePopup("This is the same concept as the Gem Scraper, except the brown integers are the scrap value.","speaking")
	if stage == 26 and not stageActive:
		stageActive = true
		activatePopup("Scrap is very important, as this allows you to fabricate turrets, which I will show you how to do now.","speaking")
	if stage == 27 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		materialAtomizer.atomizerMenu.hide()
		stageActive = true
		activatePopup("First, select the fabricator here to open its menu.","speaking")
	if stage == 28 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("Now click the button below any turret to spend scrap to manually fabricate it.","speaking")
	if stage == 29 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("As you can see, turrets take time to fabricate, let's assign a Citizen to do it for you.","speaking")
	if stage == 30 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("Select any worker and move them to the Fabricator.","speaking")
	if stage == 31 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		fabricator.menu.show()
		activatePopup("Perfect, when a Citizen is here you can assign them to a slot, please do so now.","speaking")
	if stage == 32 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("Now click the button next to the worker and select a turret to have that worker auto fabricate that turret when you have enough resources.","speaking")
	if stage == 33 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("You can always click the turret icon next to it to reassign if you need, or move the worker out of the fabricator to stop the process.","speaking")
	if stage == 34 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		fabricator.menu.show()
		activatePopup("Lastly, you can click on the turret icons above to assign them specific targets, please do so now.","speaking")
	if stage == 35 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("This will be important later, so keep this in mind for now.","speaking")
	if stage == 36 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("Great, now lastly open the research lab...this is where you spend energy to upgrade your turrets to make them better.","speaking")
	if stage == 37 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("You need to buy a slot first before you can begin research, I'll provide the simulated funds now.","speaking")
		CityManager.currentMoney += 100
	if stage == 38 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("You are now able to research turrets to another Tier, the number above the turret represents the current tier.","speaking")
	if stage == 39 and not stageActive:
		researchLab.menu.show()
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("You can assign citizens here to decrease research times, all they have to do is be in the area and they'll research all turrets.","speaking")
	if stage == 40 and not stageActive:
		researchLab.menu.hide()
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("That's currently everything in the City, now lets go to space to see what our objective is.","happy")
	if stage == 41 and not stageActive:
		cityCanvas.hide()
		towerDefenseScene.show()
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("This is a simulated area of what our environment will be like when we begin to travel the stars; with our beautiful city in the center.","speaking")
	if stage == 42 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("Commander, our primary objective is to get to the edge of the Universe.....we must protect the city at all costs to achieve this.","speaking")
	if stage == 43 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("We will need to pass through 5 Systems, each with 10 Waves of paracasual shapes attempting to stop us.","speaking")
	if stage == 44 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("If you look below, you'll see where the turrets we fabricated are, select one and place it anywhere in space.","speaking")
		if GameManager.turretStorage.size() <= 0:
			GameManager.turretStorage = {Turret.TurretID.ARROW_TURRET : 3}
		towerDefenseScene.refreshUI()
	if stage == 45 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("Hovering over a turret will display it's stats including it's current armor and health.","speaking")
		towerDefenseScene.refreshUI()
	if stage == 46 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("Additionally, you can click and drag on a turret to manually set a target enemy for it.","speaking")
		towerDefenseScene.refreshUI()
	if stage == 47 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("There is no limit to the turrets we can place, use this to your tactical advantage.","speaking")
		towerDefenseScene.refreshUI()
	if stage == 49 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("You can transition between space and your city by pressing SPACE, please do so now.","speaking")
	if stage == 50 and not stageActive:
		cityCanvas.show()
		towerDefenseScene.hide()
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("One more thing before we travel...","speaking")
	if stage == 51 and not stageActive:
		cityCanvas.show()
		towerDefenseScene.hide()
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("Here you will find resources your citizens generate if you dont auto sell or auto convert them from the buildings.","speaking")
	if stage == 52 and not stageActive:
		cityCanvas.process_mode = Node.PROCESS_MODE_ALWAYS
		stageActive = true
		activatePopup("At any time you can select the resource and convert/sell a certain amount you desire.","speaking")
	if stage == 53 and not stageActive:
		stageActive = true
		cityCanvas.hide()
		activatePopup("Well that's everything Commander...","speaking")
	if stage == 54 and not stageActive:
		stageActive = true
		cityCanvas.hide()
		activatePopup("Our City believes in you.......I know we are in good hands.","happy")
	if stage == 55 and not stageActive:
		stageActive = true
		cityCanvas.hide()
		activatePopup("I will see you in our next voyage.","happy")
	if stage == 56 and not stageActive:
		SettingsManager.mark_tutorial_done()
		animationPlayer.play("FadeOut")


func activatePopup(msg, expression):
	inputActive = false
	
	if currentPopup != null:
		currentPopup.queue_free()
		
	var commandPopup = commanderPopup.instantiate()
	add_child(commandPopup)
	currentPopup = commandPopup
	
	commandPopup.msg = msg
	commandPopup.expression = expression
	commandPopup.time = 999
	
	var popup_ui = commandPopup.get_child(0)
	var center = get_viewport_rect().size / 2.0
	var should_await = true
	
	match stage:
		0, 1, 2, 3, 30:
			popup_ui.global_position = center + Vector2(-225, -100)
		5:
			popup_ui.global_position.x += 275
		6, 22:
			popup_ui.global_position += Vector2(325, 200)
		7, 8:
			popup_ui.global_position += Vector2(650, 800)
		51, 52:
			popup_ui.global_position += Vector2(325, 500)
		9, 10, 11, 12, 13:
			popup_ui.global_position += Vector2(325, 700)
		14, 15, 16: # Gem Scraper
			popup_ui.global_position = center + Vector2(-275, -250)
		17, 18, 19, 20, 21, 25, 26, 28, 29, 31, 32, 33, 34, 35, 37, 38, 39: # Popup Menus
			popup_ui.global_position = center + Vector2(450, 0)
		23:
			popup_ui.global_position += Vector2(325, 550)
		24: # Material Atomizer
			popup_ui.global_position = center + Vector2(200, -250)
		27: # Fabricator
			popup_ui.global_position = center + Vector2(-650, -275)
		36: # Research Lab
			popup_ui.global_position = center + Vector2(500, -250)
		_:
			# Default fallback for any unlisted stages
			popup_ui.global_position = center + Vector2(-225, -250)
			should_await = false
			

	if stage == 2:
		await get_tree().create_timer(5).timeout
		skipButtonContainer.show()
		# inputActive remains false here because we want them to use the skip/continue buttons
	else:
		if should_await:
			await get_tree().create_timer(3).timeout
			
		# Reactivate input AFTER the timer finishes so the player can click again
		inputActive = true


func _on_skip_pressed() -> void:
	SettingsManager.mark_tutorial_done()
	activatePopup("Understood, we await your orders.","happy")
	skipButtonContainer.hide()
	await get_tree().create_timer(1).timeout
	animationPlayer.play("FadeOut")

func _on_continue_pressed() -> void:
	skipButtonContainer.hide()
	stage += 1
	stageActive = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeOut":
		GameManager.reset()
		get_tree().change_scene_to_file("res://Game Scenes/Main Menu.tscn")
