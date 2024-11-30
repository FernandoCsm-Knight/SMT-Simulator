extends Policy

func process_instructions_with(processor: Processor) -> Array:
	print("Processando instruções para a política BMT")
	return []

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.BMT
