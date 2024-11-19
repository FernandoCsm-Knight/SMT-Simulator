extends Panel

var start_pos: Vector2
var block_size = 50
var current_policy: Policy = null : set = configure_policy
var current_architecture: Globals.ARCHITECTURE = Globals.ARCHITECTURE.NONE : set = configure_architecture
var execution_table: ExecutionTable
var next_button: Button
var prev_button: Button
var button_container: HBoxContainer
var is_animating := false

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
	
	setup_ui()

func _on_resized():
	var panel_size = get_rect().size
	var table_width = block_size * execution_table.units_manager.get_number_of_units()
	var table_height = block_size * execution_table.clock_range
	start_pos = Vector2((panel_size.x - table_width) / 2, (panel_size.y - table_height) / 2 )
	execution_table.set_start_pos(start_pos)
	queue_redraw()

func setup_ui():
	button_container = HBoxContainer.new()
	add_child(button_container)
	
	prev_button = Button.new()
	prev_button.text = "Previous"
	prev_button.pressed.connect(_on_prev_button_pressed)
	prev_button.custom_minimum_size = Vector2(100, 30)
	button_container.add_child(prev_button)
	
	next_button = Button.new()
	next_button.text = "Next"
	next_button.pressed.connect(_on_next_button_pressed)
	next_button.custom_minimum_size = Vector2(100, 30)
	button_container.add_child(next_button)
	
	button_container.position = start_pos
	
	update_button_states()

func reset_state():
	execution_table.reset_animation()
	execution_table.reset_threads()
	is_animating = false
	update_button_states()
	queue_redraw()

func configure_architecture(architecture: Globals.ARCHITECTURE):
	if current_architecture == Globals.ARCHITECTURE.NONE:
		current_architecture = architecture
	else:
		if current_architecture != architecture:
			reset_state()
		
		current_architecture = architecture
		if current_policy and current_architecture != Globals.ARCHITECTURE.NONE:
			start_animation()

func configure_policy(policy: Policy):
	if not current_policy or current_policy.get_type() != policy.get_type():
		reset_state()
	
	current_policy = policy
	if policy.get_type() != Globals.POLICIES.NONE:
		start_animation()

func start_animation():
	is_animating = true
	execution_table.schedule(current_policy, current_architecture == Globals.ARCHITECTURE.SUPER)
	update_button_states()
	queue_redraw()

func _on_next_button_pressed():
	if execution_table.can_go_next():
		execution_table.animate_next_step()
		update_button_states()
		queue_redraw()

func _on_prev_button_pressed():
	if execution_table.can_go_prev():
		execution_table.animate_prev_step()
		update_button_states()
		queue_redraw()

func update_button_states():
	prev_button.disabled = !execution_table.can_go_prev()
	next_button.disabled = !execution_table.can_go_next()

func _draw():
	execution_table.draw(self)
