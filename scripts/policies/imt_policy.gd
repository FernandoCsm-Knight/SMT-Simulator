extends Policy

func process_instructions_with(processor: Processor) -> Array:
	var is_superscalar: bool = processor.get_architecture() == Globals.ARCHITECTURE.SUPER
	
	if is_superscalar and not _verify(processor):
		return []
	
	scheduled_instructions.clear()
	var thread_idx: int = 0
	var current_thread: ThreadInstructions
	var thread_interpolate: Dictionary = {}
	var indicies: Dictionary = {}
	var freese: Dictionary = {}
	
	while processor.has_instructions():
		processor.units_manager.free_all_units()
		current_thread = processor.thread_pool[thread_idx]
		
		for key in thread_interpolate.keys():
			if key != current_thread.get_thread_id():
				thread_interpolate[key] += 1
		
		if is_superscalar:
			var i: int = 0
			var cycle: Array[Instruction] = []
			var not_interpolate: bool = false
			
			while i < processor.instruction_fetch and processor.units_manager.has_unit_available() and i < current_thread.size():
				var inst: Instruction = current_thread.instruction_set[i]
				var dependencies: Dictionary = current_thread.get_dependencies_for(i)
				var stalls: int = current_thread.calculate_pipeline_stalls_for(i, processor.has_forwarding())
				
				
				if freese.has(inst.get_id()):
					if dependencies[Globals.DEPENDENCIES.RAW].size() == 0:
						if thread_interpolate.has(current_thread.get_thread_id()):
							not_interpolate = thread_interpolate[current_thread.get_thread_id()] == 0
							freese[inst.get_id()] -= thread_interpolate[current_thread.get_thread_id()]
				else:
					freese[inst.get_id()] = stalls

				if dependencies[Globals.DEPENDENCIES.RAW].size() == 0:
					if freese[inst.get_id()] <= 0 and processor.units_manager.is_unit_available(inst.get_required_unit()):
						freese.erase(inst.get_id())
						cycle.append(inst)
						processor.units_manager.use_unit(inst.get_required_unit())
					elif not_interpolate:
						freese[inst.get_id()] -= 1
				
				i += 1
			
			if cycle.size() > 0 or not_interpolate:
				scheduled_instructions.append(cycle)
			for inst in cycle:
				current_thread.remove(inst)
			
		elif current_thread.has_instructions():
			if not indicies.has(current_thread.get_thread_id()):
				indicies[current_thread.get_thread_id()] = 0
			
			var inst: Instruction = current_thread.instruction_set[indicies[current_thread.get_thread_id()]]
			var stalls: int = current_thread.calculate_pipeline_stalls_for(
				indicies[current_thread.get_thread_id()], 
				processor.has_forwarding()
			)
			
			var not_interpolate: bool = false
			
			if freese.has(inst.get_id()):
				if thread_interpolate.has(current_thread.get_thread_id()):
					if thread_interpolate[current_thread.get_thread_id()] > 0:
						freese[inst.get_id()] -= thread_interpolate[current_thread.get_thread_id()]
					else:
						not_interpolate = true
			else:
				if thread_interpolate.has(current_thread.get_thread_id()):
					freese[inst.get_id()] = stalls - thread_interpolate[current_thread.get_thread_id()]
				else:
					freese[inst.get_id()] = stalls
			
			if freese[inst.get_id()] <= 0: 
				freese.erase(inst.get_id())
				scheduled_instructions.append([inst])
				indicies[current_thread.get_thread_id()] += 1
			elif not_interpolate:
				scheduled_instructions.append([Instruction.new()])
				freese[inst.get_id()] -= 1
			
			if indicies[current_thread.get_thread_id()] == current_thread.size():
				processor.thread_pool[thread_idx].clear()
				indicies.erase(current_thread.get_thread_id())
		
		thread_interpolate[current_thread.get_thread_id()] = 0
		thread_idx = (thread_idx + 1) % processor.thread_pool.size()
		while not processor.thread_pool[thread_idx].has_instructions() and processor.has_instructions():
			thread_idx = (thread_idx + 1) % processor.thread_pool.size()
		
	processor.reset_threads()
	return scheduled_instructions

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.IMT
