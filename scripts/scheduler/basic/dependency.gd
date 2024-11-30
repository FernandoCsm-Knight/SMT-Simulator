extends Object
class_name Dependency

var first_instruction: Instruction
var second_instruction: Instruction
var conflict_register: String
var first_instruction_index: int
var second_instruction_index: int
var dependency_type: Globals.DEPENDENCIES

func _init(
	source_instruction: Instruction, 
	destiny_instruction: Instruction,
	conflict_reg: String,
	source_instruction_index: int, 
	destiny_instruction_index: int,
	type: Globals.DEPENDENCIES
) -> void:
	self.first_instruction = source_instruction
	self.second_instruction = destiny_instruction
	self.conflict_register = conflict_reg
	self.first_instruction_index = source_instruction_index
	self.second_instruction_index = destiny_instruction_index
	self.dependency_type = type
	
func _to_string() -> String:
	return 'Dependency({}, {}, {}, {}, {}, {})'.format([
		Globals.INSTRUCTIONS.keys()[first_instruction.operation],
		Globals.INSTRUCTIONS.keys()[second_instruction.operation],
		conflict_register,
		first_instruction_index,
		second_instruction_index,
		dependency_type], '{}')
	
