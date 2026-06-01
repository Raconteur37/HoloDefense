extends Control

var difficultyLabel
var systemLabel
var waveLabel
var intermissionLabel

var alert30Sec = false
var alert10Sec = false
var alertEnemiesIncoming = true

@onready var placeHolderTimer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	difficultyLabel = $DifficultyLabel
	systemLabel = $SystemLabel
	waveLabel = $WaveLabel
	intermissionLabel = $IntermissionLabel
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not placeHolderTimer.is_stopped():
		var time = placeHolderTimer.time_left
		var mins = int(time) / 60
		var secs = fmod(time, 60)
		
		# %02d: 2 digits, padded with a zero (e.g., 01)
		# %05.2f: 5 total spaces (00.00), padded with a zero, 2 decimal places
		intermissionLabel.text = "Intermission Time: %02d:%05.2f" % [mins, secs]
		

		if time <= 30 and not alert30Sec:
			PopupManager.enemiesIncomingPopup(time)
			alert30Sec = true
			alertEnemiesIncoming = false
		#if time <= 10 and not alert10Sec:
		#	PopupManager.enemiesIncomingPopup(time)
		#	alert10Sec = true
			
			
	if placeHolderTimer.is_stopped():
		if not alertEnemiesIncoming:
			PopupManager.enemiesIncomingPopup(0)
			alertEnemiesIncoming = true
		alert30Sec = false
		alert10Sec = false

func refreshWaveInfo(time):
	if placeHolderTimer != null:
		if placeHolderTimer.is_stopped() and time > 0:
			placeHolderTimer.wait_time = time
			placeHolderTimer.start()
		difficultyLabel.text = "Difficulty: " + str(WaveManager.currentDifficulty)
		systemLabel.text = "System: " + str(WaveManager.systemNumber) + "/5"
		waveLabel.text = "Current Wave: " + str(WaveManager.currentWave)
		intermissionLabel.text = ""
