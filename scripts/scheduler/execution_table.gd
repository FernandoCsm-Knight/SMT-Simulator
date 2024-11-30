extends ProcessingUnit
class_name ExecutionTable

var start_pos: Vector2 : set = set_start_pos
var block_size: int
var scheduled_instructions: Array
var visible_instructions: Array
var animation_index: int = 0 
var original_threads: Array
var thread_colors: Dictionary = {}

func _init(block_lenth: int, start: Vector2, clk_range: int = 6) -> void:
	super(10, clk_range)
	self.block_size = block_lenth
	self.start_pos = start
	self.scheduled_instructions = []
	self.visible_instructions = []
	self.original_threads = []
	self.thread_colors.clear()

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
	thread_colors.clear()

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

func generate_thread_color(thread_id: int) -> Color:
	if thread_colors.has(thread_id):
		return thread_colors[thread_id]
	
	var color = Color(fmod(randf(), 1.0), fmod(randf(), 1.0), fmod(randf(), 1.0), 0.7)
	thread_colors[thread_id] = color
	return color

func draw(drawable: Panel, is_superscalar: bool) -> void:
	var total_width = units_manager.get_number_of_units() * block_size if is_superscalar else block_size
	var total_height = clock_range * block_size
	
	for i in range(clock_range + 1):
		drawable.draw_line(
			Vector2(start_pos.x, start_pos.y + i * block_size), 
			Vector2(start_pos.x + total_width, start_pos.y + i * block_size), 
			Color.DARK_GRAY
		)
	
	var column: int = units_manager.get_number_of_units() + 1 if is_superscalar else 2
	for i in range(column):
		drawable.draw_line(
			Vector2(start_pos.x + i * block_size, start_pos.y),
			Vector2(start_pos.x + i * block_size, start_pos.y + total_height),
			Color.DARK_GRAY
		)
	
	var pos: Vector2
	for i in range(visible_instructions.size()):
		units_manager.reset_columns()
		for scheduled in visible_instructions[i]:
			column = 0
			if is_superscalar: column = units_manager.get_unit_column(scheduled.get_required_unit())
			pos = Vector2(start_pos.x + column * block_size, start_pos.y + i * block_size)
			
			drawable.draw_rect(
				Rect2(pos, Vector2(block_size, block_size)),
				generate_thread_color(scheduled.get_thread_id()),
				true  
			)
			
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
