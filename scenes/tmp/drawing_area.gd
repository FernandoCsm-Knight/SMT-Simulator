extends Panel

var start_pos: Vector2
var block_size = 50
var current_policy: Policy = null : set = configure_policy
var current_architecture: Globals.ARCHITECTURE = Globals.ARCHITECTURE.NONE : set = configure_architecture
var execution_table: ExecutionTable = null
var is_animating: bool = false

signal step_state_changed(can_go_previous: bool, can_go_next: bool)

func _ready():
	self.resized.connect(_on_resized)
	execution_table = ExecutionTable.new(block_size, get_rect().size / 2)
	
	execution_table.append_execution_unit(Globals.EXECUTION_UNIT.ALU)
	execution_table.append_execution_unit(Globals.EXECUTION_UNIT.ALU)
	execution_table.append_execution_unit(Globals.EXECUTION_UNIT.DATA)
	
	var first_thread: ThreadInstructions = ThreadInstructions.new(
		[
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R1', 'R2', 'R3'),
			Instruction.new(Globals.INSTRUCTIONS.LW, 'R10', 'R11', 'R5'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R5', 'R1', 'R6'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R5', 'R2', 'R3'),
			Instruction.new(Globals.INSTRUCTIONS.MUL, 'R7', 'R4', 'R8'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R2', 'R7', 'R3'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R9', 'R4', 'R10'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R11', 'R4', 'R6')
		]
	)
	
	var second_thread: ThreadInstructions = ThreadInstructions.new(
		[
			Instruction.new(Globals.INSTRUCTIONS.SUB, 'R2', 'R3', 'R4'),
			Instruction.new(Globals.INSTRUCTIONS.LW, 'R0', 'R11', 'R2'),
			Instruction.new(Globals.INSTRUCTIONS.LW, 'R1', 'R11', 'R3'),
			Instruction.new(Globals.INSTRUCTIONS.SLT, 'R0', 'R0', 'R1'),
			Instruction.new(Globals.INSTRUCTIONS.SUB, 'R0', 'R0', 'R0'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R2', 'R7', 'R3'),
		]
	)
	
	execution_table.append_thread(first_thread)
	execution_table.append_thread(second_thread)
	
	if current_policy != null:
		start_animation()
	else:
		update_button_states()

func reset_state():
	if execution_table != null:
		execution_table.reset_animation()
		execution_table.reset_threads()
		is_animating = false
		update_button_states()
		queue_redraw()

func configure_architecture(architecture: Globals.ARCHITECTURE):
	if current_architecture != architecture:
		reset_state()
	
	current_architecture = architecture
	if current_policy and current_architecture != Globals.ARCHITECTURE.NONE:
		start_animation()
	
	if execution_table != null:
		_on_resized()

func configure_policy(policy: Policy):
	if not current_policy or current_policy.get_type() != policy.get_type():
		reset_state()
	
	current_policy = policy
	if policy.get_type() != Globals.POLICIES.NONE:
		start_animation()

func start_animation():
	if execution_table != null:
		is_animating = true
		execution_table.schedule(current_policy, current_architecture == Globals.ARCHITECTURE.SUPER)
		update_button_states()
		queue_redraw()

func next_step():
	if execution_table.can_go_next():
		execution_table.animate_next_step()
		update_button_states()
		queue_redraw()

func previous_step():
	if execution_table.can_go_prev():
		execution_table.animate_prev_step()
		update_button_states()
		queue_redraw()

func _on_resized():
	var table_width = block_size
	if current_architecture == Globals.ARCHITECTURE.SUPER:
		table_width *= execution_table.units_manager.get_number_of_units()
	
	var panel_size = get_rect().size
	var table_height = block_size * execution_table.clock_range
	start_pos = Vector2((panel_size.x - table_width) / 2, (panel_size.y - table_height) / 2 )
	execution_table.set_start_pos(start_pos)
	queue_redraw()

func update_button_states():
	step_state_changed.emit(execution_table.can_go_prev(), execution_table.can_go_next())

func _draw():
	execution_table.draw(self, current_architecture == Globals.ARCHITECTURE.SUPER)
