extends Node

var cityLevel : int = 1

var cityExperienceCap : float = 100

func generateBaseCitizenExperienceLevel():
	
	var lower_offset = randf_range(cityLevel * 0.1, cityLevel * 0.2)  # 10-20% reduction
	var lower_bound = max(0.0, cityLevel - lower_offset)  

	var upper_offset = randf_range(cityLevel * 0.2, cityLevel * 0.4)  # 20-40% increase
	var upper_bound = cityLevel + upper_offset  

	lower_bound = snappedf(lower_bound, 0.1)
	upper_bound = snappedf(upper_bound, 0.1)

	return [lower_bound, upper_bound]
