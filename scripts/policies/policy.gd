class_name Policy
extends Node

var scheduled_instructions: Array = []

func enter():
	pass

func exit():
	pass

func process_instructions(is_superscalar: bool, processor: ProcessingUnit) -> Array:
	return []

func get_type() -> Globals.POLICIES:
	return Globals.POLICIES.NONE
