extends Node
class_name Policy

var scheduled_instructions: Array = []

func _verify(processor: Processor) -> bool:
	var response: bool = true
	
	var i: int = 0
	var j: int = 0
	while i < processor.thread_pool.size() and response:
		while j < processor.thread_pool[i].size() and response:
			var inst: Instruction = processor.thread_pool[i].instruction_set[j]
			if processor.units_manager.all_units[inst.get_required_unit()] <= 0:
				response = false
			j += 1
		i += 1
	
	return response

func process_instructions_with(processor: Processor) -> Array:
	return []

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.NONE

func get_architecture_support() -> Array[Globals.ARCHITECTURE]:
	return [Globals.ARCHITECTURE.SCALAR, Globals.ARCHITECTURE.SUPER]

func support(architecture: Globals.ARCHITECTURE) -> bool:
	return architecture in get_architecture_support()
