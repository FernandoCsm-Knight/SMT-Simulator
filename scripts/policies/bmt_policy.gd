extends Policy

func get_dependencies_for_bmt(current_thread: ThreadInstructions, with_forwarding: bool = false) -> int:
	var dependencies = 0
	if(current_thread.instruction_set.size()>1):
		var curr: Instruction = current_thread.instruction_set[0]
		var other: Instruction
		other = current_thread.instruction_set[1]
		if curr.write_reg == other.op1_reg or curr.write_reg == other.op2_reg:
			if !with_forwarding:
				dependencies = 2
			elif(curr.operation == Globals.INSTRUCTIONS.LW):
				dependencies = 1
	return dependencies

func process_instructions_with(processor: Processor) -> Array:
	var is_superscalar: bool = processor.get_architecture() == Globals.ARCHITECTURE.SUPER
	if is_superscalar and not _verify(processor):
		return []
	
	scheduled_instructions.clear()
	var current_cycle = 0
	var thread_idx: int = 0
	var dependencies: Dictionary 
	var current_thread: ThreadInstructions
	var current_thread_cycle = 0
	var cycles_per_thread = 3
	var stalls
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
			var instruction: Instruction 
			stalls = get_dependencies_for_bmt(current_thread, processor.has_forwarding())		
			# print(current_thread.instruction_set[0], stalls)
			if(stalls > 0):
				var blocked = processor.next_thread(thread_idx)
				if(blocked[0]):
					instruction = current_thread.instruction_set[0]
					current_thread.remove_at(0)
					scheduled_instructions[current_cycle].append(instruction)
					current_cycle+=1
					scheduled_instructions.append([])
					thread_idx = blocked[1]
					current_thread = processor.thread_pool[thread_idx]	
					stalls=0
				else:
					for i in range(stalls):
						current_thread.instruction_set.insert(1, Instruction.new())	
						instruction = current_thread.instruction_set[0]
						current_thread.remove_at(0)
						scheduled_instructions[current_cycle].append(instruction)
						current_cycle+=1
						scheduled_instructions.append([])
				instruction = current_thread.instruction_set[0]
				current_thread.remove_at(0)
				scheduled_instructions[current_cycle].append(instruction)
				stalls=0
			else:
				instruction = current_thread.instruction_set[0]
				current_thread.remove_at(0)
				scheduled_instructions[current_cycle].append(instruction)
		if(current_thread_cycle < cycles_per_thread-1):
			current_thread_cycle +=1
		else:
			thread_idx = (thread_idx + 1) % processor.thread_pool.size()
			current_thread_cycle = 0
		while not processor.thread_pool[thread_idx].has_instructions() and processor.has_instructions():
			thread_idx = (thread_idx + 1) % processor.thread_pool.size()
		
		current_cycle += 1
	processor.reset_threads()
	
	#print("inst bmt fi", scheduled_instructions)
	return scheduled_instructions

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.BMT
