extends Control
class_name Unit

const BLOCK_SIZE: int = 70

var current_unit_type: Globals.EXECUTION_UNIT = Globals.EXECUTION_UNIT.NONE:
	set = set_unit_type,
	get = get_unit_type

var clock_range: int = 1 : set = set_clock_range, get = get_clock_range
var id: int : get = get_id
var vertical_border: Vector2 = Vector2(4, 4) : set = set_vertical_border, get = get_vertical_border
var horizontal_border: int = 4 : set = set_horizontal_border, get = get_horizontal_border 

var instruction_slots: Array[Slot] = [] 
var current_instruction: int = 0 : set = set_current_instruction, get = get_current_instruction
var in_use: bool = false : get = is_in_use

@export var packed: PackedScene = null
@export var column: VBoxContainer = null
@export var dropdown: OptionButton = null
@export var container: VBoxContainer = null

signal functional_unit_updated(old_type: Globals.EXECUTION_UNIT, unit: Unit)

func _init() -> void:
	id = ResourceUID.create_id()

func _ready() -> void:
	var slot: Slot
	
	for i in range(clock_range):
		slot = _new_slot()
		instruction_slots.append(slot)
		column.add_child(slot)
	
	for key in Globals.EXECUTION_UNIT.keys():
		dropdown.add_item(key)
	
	dropdown.select(current_unit_type)
	_reset_column_borders()

func _reset_column_borders():
	var children: Array[Node] = column.get_children()
	
	if children.size() == 1:
		children[0].set_border_size(vertical_border.x, horizontal_border, vertical_border.y, horizontal_border)
	else:
		for i in range(children.size()):
			if children[i] is Slot:
				var top: int = horizontal_border if i == 0 else horizontal_border/2
				var bottom: int = horizontal_border if i == children.size() - 1 else horizontal_border/2
				
				children[i].set_border_size(vertical_border.x, top, vertical_border.y, bottom)

func set_clock_range(clk_range: int):
	clock_range = clk_range

func get_clock_range() -> int:
	return clock_range

func reset():
	current_instruction = 0
	for slot: Slot in instruction_slots:
		slot.clear_instruction()

func shift_window_up(inst: Instruction, color: Color = Color.TRANSPARENT):
	if current_instruction == clock_range:
		current_instruction -= 1
	
	for i in range(current_instruction, 0, -1):
		instruction_slots[i].set_instruction(
			instruction_slots[i - 1].get_instruction(), 
			instruction_slots[i - 1].get_color()
		)
	
	current_instruction += 1
	instruction_slots[0].set_instruction(inst, color)

func shift_window_down(inst: Instruction, color: Color = Color.TRANSPARENT):
	if current_instruction >= clock_range:
		for i in range(instruction_slots.size() - 1):
			instruction_slots[i].set_instruction(
				instruction_slots[i + 1].get_instruction(),
				instruction_slots[i + 1].get_color()
			)
		
		current_instruction -= 1
	
	instruction_slots[current_instruction].set_instruction(inst, color)
	current_instruction += 1

func shift_window_down_with_stall():
	shift_window_down(Instruction.new())

func shift_window_up_with_stall():
	shift_window_up(Instruction.new())

func set_current_instruction(index: int):
	current_instruction = index

func get_current_instruction() -> int:
	return current_instruction

func remove_back():
	if current_instruction > 0:
		current_instruction -= 1
		var slot: Slot = instruction_slots[current_instruction] as Slot
		slot.clear_instruction()

func get_id() -> int:
	return id

func set_unit_type(unit: Globals.EXECUTION_UNIT):
	current_unit_type = unit

func get_unit_type() -> Globals.EXECUTION_UNIT:
	return current_unit_type

func set_borders(vertical: Vector2, horizontal: int):
	vertical_border = vertical
	horizontal_border = horizontal
	_reset_column_borders()

func set_vertical_border(vertical: Vector2):
	vertical_border = vertical
	_reset_column_borders()

func get_vertical_border() -> Vector2:
	return vertical_border

func set_horizontal_border(horizontal: int):
	horizontal_border = horizontal
	_reset_column_borders()

func get_horizontal_border() -> int:
	return horizontal_border

func is_in_use() -> bool:
	return in_use

func alloc():
	in_use = true

func free_unit():
	in_use = false

func _new_slot() -> Slot:
	var slot = packed.instantiate() as Slot
	slot.set_block_size(BLOCK_SIZE)
	return slot

func clear():
	dropdown.select(Globals.EXECUTION_UNIT.NONE)
	for child in get_children():
		column.remove_child(child)
	instruction_slots.clear()

func _on_option_button_item_selected(index: int) -> void:
	var old_type: Globals.EXECUTION_UNIT = current_unit_type
	current_unit_type = Globals.EXECUTION_UNIT.values()[index]
	functional_unit_updated.emit(old_type, self)

func _on_v_box_container_resized() -> void:
	custom_minimum_size = container.size
