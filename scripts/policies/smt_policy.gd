extends Policy

func enter():
	print("Entrando na política SMT")

func exit():
	print("Saindo da política SMT")

func process_instructions(is_superscalar: bool, processor: ProcessingUnit) -> Array:
	print("Processando instruções para a política SMT")
	return []

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.SMT
