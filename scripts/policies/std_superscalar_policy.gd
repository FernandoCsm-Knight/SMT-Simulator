extends Policy
class_name SuperscalarPolicy

func process_instructions_with(processor: Processor) -> Array:
	if not _verify(processor):
		return []
	
	scheduled_instructions.clear()
	
	var curr_idx: int = 0
	var freese: Dictionary = {}
	var curr: ThreadInstructions = null
	while processor.has_instructions():
		curr = processor.thread_pool[0]
		
		var i: int = 0
		var cycle: Array[Instruction] = []
		processor.units_manager.free_all_units()
		while i < processor.instruction_fetch and i < curr.size() and processor.units_manager.has_unit_available():
			var inst: Instruction = curr.instruction_set[i]
			var dependencies: Dictionary = curr.get_dependencies_for(i)
			var stalls: int = curr.calculate_pipeline_stalls_for(i, processor.has_forwarding())
			
			if stalls != 0:
				stalls += 1
			
			if freese.has(inst.get_id()):
				freese[inst.get_id()] = max(freese[inst.get_id()] - 1, stalls)
			else:
				freese[inst.get_id()] = stalls
			
			if dependencies[Globals.DEPENDENCIES.RAW].size() == 0 and freese[inst.get_id()] <= 0:
				if processor.units_manager.is_unit_available(inst.get_required_unit()):
					freese.erase(inst.get_id())
					processor.units_manager.use_unit(inst.get_required_unit())
					cycle.append(inst)
			
			i += 1
		
		for inst in cycle:
			curr.remove(inst)
		
		scheduled_instructions.append(cycle)
		if curr.is_empty():
			processor.thread_pool.remove_at(0)
	
	processor.reset_threads()
	return scheduled_instructions

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.STD_SUPERSCALAR

func get_architecture_support() -> Array[Globals.ARCHITECTURE]:
	return [Globals.ARCHITECTURE.SUPER]
