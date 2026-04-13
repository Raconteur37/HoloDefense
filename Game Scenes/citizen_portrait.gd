extends TextureButton

var citizen : Citizen

func linkCitizen(citizen):
	self.citizen = citizen
	
func updatePortrait():
	print("updated citizen portrait")

func _on_pressed() -> void:
	var selectionManager = get_tree().current_scene.find_child("SelectionManager")
	
	if not Input.is_key_pressed(KEY_SHIFT):
		selectionManager.singleSelect(citizen.global_position)
	else:
		citizen.selected = true
		if not CityManager.citizensSelected.has(citizen):
			CityManager.citizensSelected.append(citizen)
