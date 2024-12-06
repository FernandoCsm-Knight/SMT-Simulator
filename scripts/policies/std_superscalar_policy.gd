extends Policy

func process_instructions_with(processor: Processor) -> Array:
	return []

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.STD_SUPERSCALAR
