extends Policy

func process_instructions_with(processor: Processor) -> Array:
	scheduled_instructions.clear()
	
	var stalls: int
	var curr_thread: ThreadInstructions
	while not processor.thread_pool.is_empty():
		curr_thread = processor.thread_pool.pop_front() as ThreadInstructions
		for i: int in range(curr_thread.instruction_set.size()):
			stalls = curr_thread.calculate_pipeline_stalls_for(i, processor.has_forwarding())
			
			for j in range(stalls):
				scheduled_instructions.append([Instruction.new()])
			
			scheduled_instructions.append([curr_thread.instruction_set[i]])
	
	processor.reset_threads()
	return scheduled_instructions

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.STD_SCALAR

func get_architecture_support() -> Array[Globals.ARCHITECTURE]:
	return [Globals.ARCHITECTURE.SCALAR]
