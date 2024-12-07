extends Object
class_name Processor

var architecture: Globals.ARCHITECTURE:
	set = set_architecture,
	get = get_architecture

var clock_range: int:
	set = set_clock_range,
	get = get_clock_range

var instruction_fetch: int:
	set = set_instruction_fetch,
	get = get_instruction_fetch

var policy: Policy:
	set = set_policy,
	get = get_policy

var forwarding: bool:
	set = set_forwarding,
	get = has_forwarding

var displayer: Displayer = null:
	set = set_displayer,
	get = get_displayer 

var units_manager: UnitsManager
var thread_pool: Array[ThreadInstructions]
var _scheduled: Array
var _immutable_thread_pool: Array[ThreadInstructions]
var _thread_colors: Dictionary

func _init(
	architecture_type: Globals.ARCHITECTURE = Globals.ARCHITECTURE.NONE,
	clk_range: int = 6, 
	fetch_order: int = 10,
	thread_support: Policy = Policy.new(),
	with_forwarding: bool = false
) -> void:
	set_architecture(architecture_type)
	set_clock_range(clk_range)
	set_instruction_fetch(fetch_order)
	set_policy(thread_support)
	set_forwarding(with_forwarding)
	
	self.thread_pool = []
	self.units_manager = UnitsManager.new()
	_immutable_thread_pool = []
	_thread_colors = {}
	_scheduled = []

func _generate_thread_color(thread_id: int):
	if not _thread_colors.has(thread_id):
		var color = Color(fmod(randf(), 1.0), fmod(randf(), 1.0), fmod(randf(), 1.0), 0.7)
		_thread_colors[thread_id] = color

func _update_displayer():
	if has_displayer():
		var stalls: int = 0
		var unused_units: int = 0
		var operations: int = 0
		var cycles: int = _scheduled.size()
		var usage: float = 0.0
		
		if architecture == Globals.ARCHITECTURE.SCALAR:
			for inst in _scheduled:
				if inst[0].operation == Globals.INSTRUCTIONS.STALL or inst[0].operation == Globals.INSTRUCTIONS.TRASH:
					stalls += 1
				else:
					operations += 1
			usage = float(cycles - stalls)/float(cycles)
		else:
			for arr in _scheduled:
				if arr.size() == 0:
					stalls += 1
				else:
					operations += arr.size()
			usage = float(operations) / float(cycles * units_manager.size())
		
		displayer.set_architecture(architecture)
		displayer.set_thread_support(policy.get_type())
		displayer.set_stalls(stalls)
		displayer.set_cycles(cycles)
		displayer.set_ipc(float(operations)/float(cycles))
		displayer.set_cpi(float(cycles)/float(operations))
		displayer.set_usage(usage)

func has_displayer() -> bool:
	return displayer != null

func get_thread_color(thread_id: int) -> Color:
	return _thread_colors[thread_id] if _thread_colors.has(thread_id) else Color.TRANSPARENT

func get_thread_support() -> Globals.POLICIES:
	return policy.get_type()

func set_forwarding(value: bool):
	forwarding = value

func has_forwarding() -> bool:
	return forwarding

func set_architecture(architecture_type: Globals.ARCHITECTURE):
	architecture = architecture_type
	if policy and not policy.support(architecture):
		policy = Policy.new()

func get_architecture() -> Globals.ARCHITECTURE:
	return architecture

func set_clock_range(clk_range: int):
	clock_range = clk_range

func get_clock_range() -> int:
	return clock_range

func set_instruction_fetch(fetch_order: int):
	instruction_fetch = fetch_order

func get_instruction_fetch() -> int:
	return instruction_fetch

func set_policy(thread_support: Policy):
	if thread_support and thread_support.support(architecture):
		policy = thread_support
	else: policy = Policy.new()

func get_policy() -> Policy:
	return policy

func reset_threads():
	thread_pool.clear()
	_thread_colors.clear()
	for thread in _immutable_thread_pool:
		var new_thread: ThreadInstructions = ThreadInstructions.new(thread.instruction_set)
		thread_pool.append(new_thread)
		_generate_thread_color(new_thread.get_thread_id())

func append_functional_unit(unit: Globals.EXECUTION_UNIT) -> bool:
	units_manager.append(unit)
	return true

func remove_functional_unit(unit: Globals.EXECUTION_UNIT) -> bool:
	return units_manager.remove(unit)

func append_thread(thread: ThreadInstructions):
	_immutable_thread_pool.append(ThreadInstructions.new(thread.instruction_set))
	thread_pool.append(thread)
	_generate_thread_color(thread.thread_id)

func remove_thread(thread_id: int) -> bool:
	for i in range(thread_pool.size()):
		if thread_pool[i].thread_id == thread_id:
			_immutable_thread_pool.remove_at(i)
			thread_pool.remove_at(i)
			_thread_colors.erase(thread_id)
			return true
	
	return false

func has_instructions() -> bool:
	var some: bool = false
	for thread: ThreadInstructions in thread_pool:
		if thread.has_instructions():
			some = true
	return some

func get_scheduled_instructions() -> Array:
	return _scheduled if _scheduled != null else []

func process_instructions() -> Array:
	if not is_empty() and has_instructions() and policy:
		_scheduled = policy.process_instructions_with(self)
		_update_displayer()
		return _scheduled
	else:
		return []

func is_empty() -> bool:
	return units_manager.get_number_of_units() == 0 or thread_pool.is_empty()

func set_displayer(interface: Displayer):
	displayer = interface

func get_displayer() -> Displayer:
	return displayer

func clear():
	thread_pool.clear()
	units_manager.clear()
	_immutable_thread_pool.clear()
	_thread_colors.clear()

func _to_string() -> String:
	return 'CPU({}, {}, {}, {})'.format([
		Globals.ARCHITECTURE.keys()[architecture],
		clock_range,
		instruction_fetch,
		Globals.POLICIES.keys()[get_thread_support()]
	], '{}')
