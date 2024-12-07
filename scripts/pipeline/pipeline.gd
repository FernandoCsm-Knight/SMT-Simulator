extends Control
class_name Pipeline

var stalls: Dictionary = {}
var current_processor: Processor = null: set = reset_state
var scheduled_instructions: Array = []
var animation_index: int = 0
var end_cycles: int = 0
var last_instruction_id: int = -1

@export var manager: StageManager = null

func can_go_next() -> bool:
	var can_go_over: bool = (animation_index > 0 and end_cycles < manager.pipeline_size())
	return animation_index < scheduled_instructions.size() or can_go_over

func can_go_prev() -> bool:
	return animation_index > 0

func _count_stalls_for(instruction: Instruction) -> Instruction:
	if scheduled_instructions[animation_index - 1][0].operation != Globals.INSTRUCTIONS.STALL:
		
		var key: int = scheduled_instructions[animation_index - 1][0].get_id()
		stalls[key] = 0
		
		while instruction.operation == Globals.INSTRUCTIONS.STALL:
			stalls[key] += 1
			animation_index += 1
			instruction = scheduled_instructions[animation_index][0]
		
	return instruction

func forward():
	if stalls.has(last_instruction_id) and stalls[last_instruction_id] == 0:
		stalls.erase(last_instruction_id)
		last_instruction_id = -1
	
	var curr := manager.get_stage(Globals.PIPELINE_STAGES.EX).get_instruction()
	if stalls.has(curr.get_id()): last_instruction_id = curr.get_id()
	
	if last_instruction_id != -1 and stalls.has(last_instruction_id):
		stalls[last_instruction_id] -= 1
		manager.forward_stall()
	elif animation_index < scheduled_instructions.size():
		var original: Instruction = scheduled_instructions[animation_index][0] 
		
		if original.operation == Globals.INSTRUCTIONS.STALL and animation_index > 0:
			original = _count_stalls_for(original)
		
		manager.forward(original, current_processor.get_thread_color(original.get_thread_id()))
		animation_index += 1
	else:
		manager.forward(Instruction.new())
		end_cycles += 1

func _found_next_instruction() -> Instruction:
	var response: Instruction = null
	
	var found: bool = false
	var i: int = Globals.PIPELINE_STAGES.EX
	while not found and i < manager.pipeline_size():
		var curr := manager.get_stage(i).get_instruction()
		if curr.operation != Globals.INSTRUCTIONS.STALL:
			response = curr
			found = true
		i += 1
	
	return response

func _stalls_until_ex() -> int:
	var response: int = 0
	
	var inst_id: int = -1
	for i in range(Globals.PIPELINE_STAGES.EX + 1):
		inst_id = manager.get_stage(i).get_instruction().get_id()
		if stalls.has(inst_id):
			response += stalls[inst_id]
	
	return response

func _verify_stalls():
	if animation_index < scheduled_instructions.size():
		var inst: Instruction = scheduled_instructions[animation_index][0]
		while inst.operation == Globals.INSTRUCTIONS.STALL and animation_index > 0:
			animation_index -= 1
			inst = scheduled_instructions[animation_index][0]
		
		if animation_index > 0 and stalls.has(inst.get_id()):
			stalls.erase(inst.get_id())

func backward():
	var curr := manager.get_stage(Globals.PIPELINE_STAGES.EX).get_instruction()
	var inst: Instruction = null
	if curr.operation == Globals.INSTRUCTIONS.STALL:
		inst = _found_next_instruction()
	
	if inst != null and end_cycles < Globals.PIPELINE_STAGES.EX:
		if inst != null: 
			if stalls.has(inst.get_id()):
				stalls[inst.get_id()] += 1
			else:
				stalls[inst.get_id()] = 1
		
		var index: int = animation_index - manager.pipeline_size() - _stalls_until_ex() - stalls[inst.get_id()] + end_cycles
		if index > 0:
			var instruction: Instruction = scheduled_instructions[index][0]
			manager.backward_stall(instruction, current_processor.get_thread_color(instruction.get_thread_id()))
		else:
			manager.backward_stall()
	else:
		if animation_index <= manager.pipeline_size():
			manager.backward()
		else:
			var index: int = animation_index - manager.pipeline_size() - 1 - _stalls_until_ex() + end_cycles
			var instruction: Instruction = scheduled_instructions[index][0] 
			manager.backward(instruction, current_processor.get_thread_color(instruction.get_thread_id()))
		
		if end_cycles == 0: animation_index -= 1
		else: end_cycles -= 1
	
	_verify_stalls()

func reset_state(processor: Processor) -> void:
	current_processor = processor
	end_cycles = 0
	last_instruction_id = -1
	stalls.clear()
	if not processor.is_empty():
		scheduled_instructions = processor.process_instructions()
		print(scheduled_instructions)
		animation_index = 0
	manager.reset_state()
