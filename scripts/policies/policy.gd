extends Node
class_name Policy

var scheduled_instructions: Array = []

func process_instructions_with(processor: Processor) -> Array:
	return []

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.NONE
