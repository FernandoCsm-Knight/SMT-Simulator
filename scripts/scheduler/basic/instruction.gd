extends Object
class_name Instruction

var id: int : get = get_id
var thread_id: int = -1: get = get_thread_id , set = set_thread_id
var required_unit: Globals.EXECUTION_UNIT : get = get_required_unit
var operation: Globals.INSTRUCTIONS
var write_reg: String
var op1_reg: String
var op2_reg: String
var branch_target_label: String
var branch_target_index: int

func _init(
	instruction_type: Globals.INSTRUCTIONS = Globals.INSTRUCTIONS.STALL, 
	write_register: String = '', 
	op1_register: String = '', 
	op2_register: String = '',
	branch_target: String = '', 
	branch_index: int = -1
) -> void:
	self.id = ResourceUID.create_id()
	self.operation = instruction_type
	self.write_reg = write_register
	self.op1_reg = op1_register
	self.op2_reg = op2_register
	self.branch_target_label = branch_target
	self.branch_target_index = branch_index
	
	required_unit = get_required_unit_for(self.operation)

static func get_required_unit_for(op: Globals.INSTRUCTIONS) -> Globals.EXECUTION_UNIT:
	match op:
		Globals.INSTRUCTIONS.ADD, Globals.INSTRUCTIONS.SUB, Globals.INSTRUCTIONS.SLT, Globals.INSTRUCTIONS.MUL, Globals.INSTRUCTIONS.DIV, Globals.INSTRUCTIONS.AND, Globals.INSTRUCTIONS.OR, Globals.INSTRUCTIONS.XOR:
			return Globals.EXECUTION_UNIT.ALU
		Globals.INSTRUCTIONS.LW, Globals.INSTRUCTIONS.SW:
			return Globals.EXECUTION_UNIT.DATA
		Globals.INSTRUCTIONS.BEQ, Globals.INSTRUCTIONS.BNE, Globals.INSTRUCTIONS.JAL:
			return Globals.EXECUTION_UNIT.CONTROL
		Globals.INSTRUCTIONS.FADD, Globals.INSTRUCTIONS.FMUL, Globals.INSTRUCTIONS.FDIV, Globals.INSTRUCTIONS.FSQRT:
			return Globals.EXECUTION_UNIT.FPU
		_:
			return Globals.EXECUTION_UNIT.ALU

func get_required_unit() -> Globals.EXECUTION_UNIT:
	return required_unit

func get_id() -> int:
	return id

func get_thread_id() -> int:
	return thread_id

func set_thread_id(t_id: int):
	thread_id = t_id

func is_stall() -> bool:
	return operation == Globals.INSTRUCTIONS.STALL

func _to_string() -> String:
	var response: String
	if branch_target_label.length() == 0:
		response = 'Instruction({}, {}, {}, {})'.format([
			Globals.INSTRUCTIONS.keys()[operation],
			write_reg,
			op1_reg,
			op2_reg
		], '{}')
	else:
		response = 'Instruction({}, {}, {}, {}, {})'.format([
			Globals.INSTRUCTIONS.keys()[operation],
			write_reg,
			op1_reg,
			op2_reg, 
			branch_target_label
		], '{}')
	return response
