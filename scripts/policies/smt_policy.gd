extends Policy

func process_instructions_with(processor: Processor) -> Array:
	print("Processando instruções para a política SMT")
	return []

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.SMT
