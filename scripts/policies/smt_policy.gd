extends Policy

func get_dependencies_for_smt(index: int, all_instructions) -> Dictionary:
	var curr = all_instructions[index]
	var other
	var dependencies = {
		Globals.DEPENDENCIES.RAW: [],
		Globals.DEPENDENCIES.WAW: [],
		Globals.DEPENDENCIES.WAR: []
	}
	
	for i in range(index):
		other = all_instructions[i]
		if(curr[0]!=other[0]):
			pass
		else:
			if other[1].write_reg == curr[1].op1_reg or other[1].write_reg == curr[1].op2_reg:
				dependencies[Globals.DEPENDENCIES.RAW].append(Dependency.new(
					other[1], curr[1], other[1].write_reg, i, index, Globals.DEPENDENCIES.RAW
				))
			
			if other[1].write_reg == curr[1].write_reg:
				dependencies[Globals.DEPENDENCIES.WAW].append(Dependency.new(
					other[1], curr[1], other[1].write_reg, i, index, Globals.DEPENDENCIES.WAW
				))
		
			if other[1].op1_reg == curr[1].write_reg or other[1].op2_reg == curr[1].write_reg:
				dependencies[Globals.DEPENDENCIES.WAR].append(Dependency.new(
					other[1], curr[1], curr[1].write_reg, i, index, Globals.DEPENDENCIES.WAR
				))
	return dependencies

func process_instructions_with(processor: Processor) -> Array:
	scheduled_instructions.clear()
	var is_superscalar: bool = processor.get_architecture() == Globals.ARCHITECTURE.SUPER
	var current_cycle = 0
	var thread_idx: int = 0
	var dependencies: Dictionary 
	var current_thread: ThreadInstructions
	var all_instructions = []
	var gone = []
	current_thread = processor.thread_pool[thread_idx]
	while(!processor.thread_pool.is_empty()):
		if(current_thread.instruction_set.size()>0):
			all_instructions.append([thread_idx,current_thread.instruction_set[0]])
			current_thread.instruction_set.pop_front()
		else:
			processor.thread_pool.remove_at(thread_idx)
		if(!processor.thread_pool.is_empty()):
			thread_idx = (thread_idx + 1) % processor.thread_pool.size()
			current_thread = processor.thread_pool[thread_idx]
	print("all inst", all_instructions)
	print("deps smt", dependencies)
	#$while !all_instructions.is_empty():
	var inst_idx: int = 0
	while all_instructions.size()>0:
		processor.units_manager.free_all_units()
		scheduled_instructions.append([])
		var i = 0
		while(i<all_instructions.size()):
			dependencies = get_dependencies_for_smt(i, all_instructions)
			if dependencies[Globals.DEPENDENCIES.RAW].size() == 0:
				if processor.units_manager.is_unit_available(all_instructions[i][1].get_required_unit()):
					scheduled_instructions[current_cycle].append(all_instructions[i][1])
					processor.units_manager.use_unit(all_instructions[i][1].get_required_unit())
					gone.append(all_instructions[i])
			i+=1
		for j in gone:
			all_instructions.erase(j)
		current_cycle += 1
	#while inst_idx < all_instructions.size() and processor.units_manager.has_unit_available():
		#processor.units_manager.free_all_units()
		#scheduled_instructions.append([])
		#dependencies = get_dependencies_for_smt(inst_idx, all_instructions)
		#processor.units_manager.has_unit_available()
		#var instruction: Instruction = all_instructions[inst_idx][1]
		#if dependencies[Globals.DEPENDENCIES.RAW].size() == 0:
			#if processor.units_manager.is_unit_available(instruction.get_required_unit()):
				#scheduled_instructions[current_cycle].append(instruction)
				#processor.units_manager.use_unit(instruction.get_required_unit())
		#
		#inst_idx += 1
		#
		#for inst in scheduled_instructions[current_cycle]:
			#current_thread.remove(inst)
		
		#thread_idx = (thread_idx + 1) % processor.thread_pool.size()
		#while not processor.thread_pool[thread_idx].has_instructions() and processor.has_instructions():
		#	thread_idx = (thread_idx + 1) % processor.thread_pool.size()
		
		#if current_thread.get_thread_id() == processor.thread_pool[thread_idx].get_thread_id():
		#	pass # TODO: identify stalls
	print("scdl smt", scheduled_instructions)
	processor.reset_threads()
	return scheduled_instructions

func get_architecture_support() -> Array[Globals.ARCHITECTURE]:
	return [Globals.ARCHITECTURE.SUPER]

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.SMT
