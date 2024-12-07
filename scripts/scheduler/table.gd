extends Control
class_name Table

@export var line: HBoxContainer = null
@export var packed: PackedScene = null

var scheduled_instructions: Array = []
var animation_index: int = 0
var functional_units: Dictionary = {}
var current_processor: Processor = null : set = reset_state

func _init() -> void:
	for key in Globals.EXECUTION_UNIT.values():
		functional_units[key] = []

func _dict_to_array() -> Array[Unit]:
	var array: Array[Unit] = []
	
	for key in functional_units.keys():
		for unit in functional_units[key]:
			array.append(unit)
	
	return array

func _append_new_child(unit: Unit):
	functional_units[unit.get_unit_type()].append(unit)
	var other: Unit = line.get_children().back() as Unit if line.get_children().size() > 0 else null
	if line != null:
		if other != null:
			other.set_borders(Vector2(other.get_vertical_border().x, 2), 4)
		
		if line.get_children().size() == 0:
			unit.set_borders(Vector2(4, 4), 4)
		else:
			unit.set_borders(Vector2(2, 4), 4)
		line.add_child(unit)

func can_go_next() -> bool:
	return animation_index < scheduled_instructions.size()

func can_go_prev() -> bool:
	return animation_index > 0

func get_available_unit(unit: Globals.EXECUTION_UNIT) -> Unit:
	for instance: Unit in functional_units[unit]:
		if not instance.is_in_use():
			return instance
	
	return null

func free_all_units():
	for key in functional_units.keys():
		for unit: Unit in functional_units[key]:
			unit.free_unit()

func forward() -> void:
	free_all_units()
	
	for inst: Instruction in scheduled_instructions[animation_index]:
		var unit: Unit = get_available_unit(inst.get_required_unit())
		if unit != null:
			var color: Color = current_processor.get_thread_color(inst.get_thread_id())
			unit.shift_window_down(inst, color)
			unit.alloc()
	
	for key in functional_units.keys():
		for unit: Unit in functional_units[key]:
			if not unit.is_in_use():
				unit.shift_window_down_with_stall()
	
	animation_index += 1

func backward():
	if animation_index <= current_processor.clock_range:
		for key in functional_units.keys():
			for unit in functional_units[key]:
				unit.remove_back()
	
	else:
		free_all_units()
		var index: int = animation_index - current_processor.clock_range - 1
		
		for inst: Instruction in scheduled_instructions[index]:
			var unit: Unit = get_available_unit(inst.get_required_unit())
			if unit != null:
				var color: Color = current_processor.get_thread_color(inst.get_thread_id())
				unit.shift_window_up(inst, color)
				unit.alloc()
		
		for key in functional_units.keys():
			for unit: Unit in functional_units[key]:
				if not unit.is_in_use():
					unit.shift_window_up_with_stall()
	
	animation_index -= 1

func append_unit(unit: Globals.EXECUTION_UNIT):
	var instance: Unit = packed.instantiate() as Unit
	instance.set_unit_type(unit)
	instance.set_clock_range(current_processor.clock_range)
	instance.functional_unit_updated.connect(_on_unit_functional_unit_updated)
	_append_new_child(instance)

func number_of_units() -> int:
	return functional_units.size()

func is_empty() -> bool:
	for key in functional_units.keys():
		for units: Array in functional_units[key]:
			if not units.is_empty():
				return false
	
	return true

func reset_state(processor: Processor) -> void:
	clear()
	current_processor = processor
	
	if not processor.is_empty():
		scheduled_instructions = processor.process_instructions()
		print(scheduled_instructions)
		animation_index = 0
	
	for unit in processor.units_manager.all_units:
		for i in range(processor.units_manager.all_units[unit]):
			append_unit(unit)

func clear_children():
	var children: Array[Node] = line.get_children()
	for child in children:
		if child is Unit:
			child.functional_unit_updated.disconnect(_on_unit_functional_unit_updated)
		
		line.remove_child(child)

func clear():
	for key in Globals.EXECUTION_UNIT.values():
		functional_units[key] = []
	clear_children()

func _on_unit_functional_unit_updated(old_type: Globals.EXECUTION_UNIT, unit: Unit) -> void:
	functional_units[old_type].erase(unit)
	functional_units[unit.get_unit_type()].append(unit)
	
	print('{} unit {} updated to {}'.format([
		Globals.EXECUTION_UNIT.keys()[old_type], 
		unit.get_id(),
		Globals.EXECUTION_UNIT.keys()[unit.get_unit_type()]
	], '{}'))

func _on_h_box_container_resized() -> void:
	custom_minimum_size = line.size
