extends ProcessingUnit
class_name ExecutionTable

var start_pos: Vector2 : set = set_start_pos
var block_size: int
var scheduled_instructions: Array
var visible_instructions: Array
var animation_index: int = 0 
var original_threads: Array
var policy: Policy

func _init(block_size: int, start_pos: Vector2, clock_range: int = 6) -> void:
	super(10, clock_range)
	self.block_size = block_size
	self.start_pos = start_pos
	self.scheduled_instructions = []
	self.visible_instructions = []

func set_start_pos(position: Vector2):
	start_pos = position

func append_thread(thread: ThreadInstructions) -> void:
	super.append_thread(thread)
	original_threads.append(thread.duplicate())

func reset_threads() -> void:
	thread_pool.clear()
	for thread in original_threads:
		thread_pool.append(thread.duplicate())

func reset_animation():
	visible_instructions.clear()
	scheduled_instructions.clear()
	animation_index = 0

func can_go_next() -> bool:
	return animation_index < scheduled_instructions.size()

func can_go_prev() -> bool:
	return animation_index > 0

func animate_next_step() -> void:
	if animation_index < scheduled_instructions.size():
		if scheduled_instructions[animation_index].size() > 0:
			visible_instructions.append(scheduled_instructions[animation_index].duplicate())
		animation_index += 1

func animate_prev_step() -> void:
	if animation_index > 0:
		animation_index -= 1
		if visible_instructions.size() > 0:
			visible_instructions.pop_back()

func schedule(policy: Policy, is_superscalar: bool) -> void:
	scheduled_instructions = policy.process_instructions(is_superscalar, self)

func draw(drawable: Panel) -> void:
	var panel_size = drawable.get_rect().size
	var total_width = units_manager.get_number_of_units() * block_size
	var total_height = clock_range * block_size
	
	for i in range(clock_range + 1):
		drawable.draw_line(
			Vector2(start_pos.x, start_pos.y + i * block_size), 
			Vector2(start_pos.x + total_width, start_pos.y + i * block_size), 
			Color.DARK_GRAY
		)
	
	for i in range(units_manager.get_number_of_units() + 1):
		drawable.draw_line(
			Vector2(start_pos.x + i * block_size, start_pos.y),
			Vector2(start_pos.x + i * block_size, start_pos.y + total_height),
			Color.DARK_GRAY
		)
	
	for i in range(visible_instructions.size()):
		units_manager.reset_columns()
		for scheduled in visible_instructions[i]:
			var column: int = units_manager.get_unit_column(scheduled.get_required_unit())
			var pos = Vector2(start_pos.x + column * block_size, start_pos.y + i * block_size)
			units_manager.set_unit_column(column)
			scheduled.draw(drawable, pos, Vector2(block_size, block_size))
	
	if visible_instructions.size() > 0:
		var cycle_text = "Cycle: %d" % visible_instructions.size()
		drawable.draw_string(
			ThemeDB.fallback_font,
			Vector2(start_pos.x, start_pos.y - 20),
			cycle_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			16,
			Color.WHITE
		)
