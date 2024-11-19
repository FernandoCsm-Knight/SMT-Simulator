extends Policy

func enter():
	print("Entrando na política IMT")

func exit():
	print("Saindo da política IMT")

func process_instructions(is_superscalar: bool, processor: ProcessingUnit) -> Array:
	scheduled_instructions.clear()
	var current_cycle = 0
	var thread_idx: int = 0
	var dependencies: Dictionary 
	var current_thread: ThreadInstructions
	
	while current_cycle < processor.clock_range:
		processor.units_manager.free_all_units()
		scheduled_instructions.append([])
		current_thread = processor.thread_pool[thread_idx]
		
		if is_superscalar:
			var inst_idx: int = 0
			while inst_idx < processor.instruction_fetch_range and processor.units_manager.has_unit_available() and inst_idx < current_thread.size():
				
				dependencies = current_thread.get_dependencies_for(inst_idx)
				var instruction: Instruction = current_thread.instruction_set[inst_idx]
				if dependencies[Globals.DEPENDENCIES.RAW].size() == 0:
					if processor.units_manager.is_unit_available(instruction.get_required_unit()):
						scheduled_instructions[current_cycle].append(instruction)
						processor.units_manager.use_unit(instruction.get_required_unit())
				
				inst_idx += 1
			
			for inst in scheduled_instructions[current_cycle]:
				current_thread.remove(inst)
				
		elif current_thread.has_instructions():
			var instruction: Instruction = current_thread.instruction_set[0]
			current_thread.remove_at(0)
			scheduled_instructions[current_cycle].append(instruction)
		
		thread_idx = (thread_idx + 1) % processor.thread_pool.size()
		if processor.thread_pool[thread_idx].has_instructions(): current_cycle += 1
	
	return scheduled_instructions

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.IMT
