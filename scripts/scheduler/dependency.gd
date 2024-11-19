extends Object
class_name Dependency

var first_instruction: Instruction
var second_instruction: Instruction
var conflict_register: String
var first_instruction_index: int
var second_instruction_index: int
var dependency_type: Globals.DEPENDENCIES

func _init(
	first_instruction: Instruction, 
	second_instruction: Instruction,
	conflict_register: String,
	first_instruction_index: int, 
	second_instruction_index: int,
	dependency_type: Globals.DEPENDENCIES
) -> void:
	self.first_instruction = first_instruction
	self.second_instruction = second_instruction
	self.conflict_register = conflict_register
	self.first_instruction_index = first_instruction_index
	self.second_instruction_index = second_instruction_index
	self.dependency_type = dependency_type
	
func _to_string() -> String:
	return 'Dependency({}, {}, {}, {}, {}, {})'.format([
		Globals.INSTRUCTIONS.keys()[first_instruction.operation],
		Globals.INSTRUCTIONS.keys()[second_instruction.operation],
		conflict_register,
		first_instruction_index,
		second_instruction_index,
		dependency_type], '{}')
	
