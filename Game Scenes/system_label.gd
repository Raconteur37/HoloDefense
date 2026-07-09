extends Label

@export var typing_speed: float = 0.05 # Seconds per character

func _ready():
	# Test it out when the scene plays
	var system = WaveManager.currentSystem
	var difficulty = WaveManager.currentDifficulty
	await get_tree().create_timer(1).timeout
	start_typing("Attempt #" + str(int(StatManager.getLifetimeStat("totalRuns")) + 1) + "\n" +
	"System: " + system + "\n" +
	"Estimated Difficulty: " + str(difficulty))
	await get_tree().create_timer(3.5).timeout
	if WaveManager.currentDifficulty <= 5:
		var randPhrases = ["Goodluck Commander...","This shouldn't be too bad.","Give it your all Commander."]
		start_typing(randPhrases.pick_random())
	else:
		if WaveManager.currentDifficulty <= 8:
			var randPhrases = ["This wont be easy...","We must make it this time.","We will not fail."]
			start_typing(randPhrases.pick_random())
		else:
			var randPhrases = ["This will be the one.","There's no going back now.","No matter what, we cannot give up.","Do not fail the City.","Think of what is beyond."]
			start_typing(randPhrases.pick_random())

func start_typing(new_text: String):
	text = new_text
	visible_characters = 0 # Hide all text initially
	
	var tween = create_tween()
	
	# Calculate how long the entire animation should take
	var total_duration = new_text.length() * typing_speed
	
	# Animate 'visible_characters' from 0 to the full length of the string
	tween.tween_property(self, "visible_characters", new_text.length(), total_duration)
