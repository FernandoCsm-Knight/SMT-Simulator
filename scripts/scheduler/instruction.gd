extends Object
class_name Instruction

var id: int : get = get_id
var thread_id: int = -1: get = get_thread_id , set = set_thread_id
var required_unit: Globals.EXECUTION_UNIT : get = get_required_unit
var operation: Globals.INSTRUCTIONS
var write_reg: String
var op1_reg: String
var op2_reg: String

func _init(operation: Globals.INSTRUCTIONS, write_reg: String, op1_reg: String, op2_reg: String) -> void:
	self.id = ResourceUID.create_id()
	self.operation = operation
	self.write_reg = write_reg
	self.op1_reg = op1_reg
	self.op2_reg = op2_reg
	
	match operation:
		Globals.INSTRUCTIONS.ADD, Globals.INSTRUCTIONS.SUB, Globals.INSTRUCTIONS.SLT:
			required_unit = Globals.EXECUTION_UNIT.ALU
		Globals.INSTRUCTIONS.MUL, Globals.INSTRUCTIONS.DIV:
			required_unit = Globals.EXECUTION_UNIT.ALU 
		Globals.INSTRUCTIONS.LW, Globals.INSTRUCTIONS.SW:
			required_unit = Globals.EXECUTION_UNIT.DATA
		Globals.INSTRUCTIONS.BEQ, Globals.INSTRUCTIONS.BNE:
			required_unit = Globals.EXECUTION_UNIT.CONTROL
		_:
			required_unit = Globals.EXECUTION_UNIT.ALU

func get_required_unit() -> Globals.EXECUTION_UNIT:
	return required_unit

func get_id() -> int:
	return id

func get_thread_id() -> int:
	return thread_id

func set_thread_id(t_id: int):
	thread_id = t_id

func draw(drawable: Panel, position: Vector2, block_size: Vector2):
	var operation_string: String = Globals.INSTRUCTIONS.keys()[operation]
	var font = ThemeDB.fallback_font
	var max_font_size = floor(block_size.x / 4)
	var text_size = font.get_string_size(operation_string, HORIZONTAL_ALIGNMENT_CENTER, -1, max_font_size)
	var text_pos = position + (block_size - text_size) / 2
	drawable.draw_string(font, text_pos, operation_string, HORIZONTAL_ALIGNMENT_CENTER, -1, max_font_size, Color.WHITE)
