extends Policy

func process_instructions_with(processor: Processor) -> Array:
	scheduled_instructions.clear()
	var is_superscalar: bool = processor.get_architecture() == Globals.ARCHITECTURE.SUPER
	var current_cycle = 0
	var thread_idx: int = 0
	var dependencies: Dictionary 
	var current_thread: ThreadInstructions
	
	while processor.has_instructions():
		processor.units_manager.free_all_units()
		scheduled_instructions.append([])
		current_thread = processor.thread_pool[thread_idx]
		
		if is_superscalar:
			var inst_idx: int = 0
			while inst_idx < processor.instruction_fetch and processor.units_manager.has_unit_available() and inst_idx < current_thread.size():
				
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
		while not processor.thread_pool[thread_idx].has_instructions() and processor.has_instructions():
			thread_idx = (thread_idx + 1) % processor.thread_pool.size()
		
		current_cycle += 1
	
	processor.reset_threads()
	return scheduled_instructions

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.IMT
