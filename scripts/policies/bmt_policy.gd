extends Policy

func enter():
	print("Entrando na política BMT")

func exit():
	print("Saindo da política BMT")

func process_instructions(is_superscalar: bool, processor: ProcessingUnit) -> Array:
	print("Processando instruções para a política BMT")
	return []

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.BMT
