extends Node2D

func _process(delta: float) -> void:
	for timer in get_tree().get_nodes_in_group("Timer"):
		if timer.is_stopped() == false:
			print("⏱️ Active timer:", timer.name, " Path:", timer.get_path())
	
	var process_time = Performance.get_monitor(Performance.TIME_PROCESS)
	if process_time > 30.0:
		print("⚠️ HIGH PROCESS TIME:", process_time, "ms")
		log_running_nodes()

func log_running_nodes():
	for node in get_tree().get_nodes_in_group("node"):
		if node.is_processing():
			print("⚙️ Running:", node.name, "Class:", node.get_class(), "Path:", node.get_path())

	for node in get_tree().get_nodes_in_group("Timer"):
		if not node.is_stopped():
			print("⏱️ Active Timer:", node.name, "Time left:", node.time_left)

	for node in get_tree().get_nodes_in_group("Particles"):
		if node is GPUParticles2D or node is CPUParticles2D:
			if node.emitting:
				print("🎇 Emitting Particle:", node.name)
