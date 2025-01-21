extends Node

var isCitizenSelected : bool = false

var citizenSelected = null
var citizensSelectedList : Array = []

func citizenSelect(citizen):
	if not isCitizenSelected:
		isCitizenSelected = true
		citizenSelected = citizen

func citizenDeselect():
	if isCitizenSelected:
		isCitizenSelected = false
		citizenSelected = null
