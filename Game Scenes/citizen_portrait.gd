extends TextureButton

var citizen : Citizen

var index

func linkCitizen(citizen):
	self.citizen = citizen
	
func updatePortrait():
	print("updated citizen portrait")

func _on_pressed() -> void:
	var selectionManager = get_tree().current_scene.find_child("SelectionManager")
	
	if CityManager.assignCit:
		assignCitToFabSlot()
		return
	
	if not Input.is_key_pressed(KEY_SHIFT):
		selectionManager.singleSelect(citizen.global_position)
	else:
		citizen.selected = true
		if not CityManager.citizensSelected.has(citizen):
			CityManager.citizensSelected.append(citizen)


func assignCitToFabSlot():
	get_tree().current_scene.find_child("Fabricator").assignCit(index,citizen)

func _on_mouse_entered() -> void:
	citizen._on_area_2d_mouse_entered()


func _on_mouse_exited() -> void:
	citizen._on_area_2d_mouse_exited()
