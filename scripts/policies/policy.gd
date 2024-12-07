extends Node
class_name Policy

var scheduled_instructions: Array = []

func process_instructions_with(processor: Processor) -> Array:
	return []

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.NONE

func get_architecture_support() -> Array[Globals.ARCHITECTURE]:
	return [Globals.ARCHITECTURE.SCALAR, Globals.ARCHITECTURE.SUPER]

func support(architecture: Globals.ARCHITECTURE) -> bool:
	return architecture in get_architecture_support()
