@tool
extends Control
class_name PipelineStage

@export var stageContainer: Panel = null
@export var slotContainer: Panel = null
@export var slot: Slot = null
@export var label: Label = null

@export var min_size: int = 150:
	set(value):
		min_size = value
		custom_minimum_size = Vector2(value, value)

@export var type: Globals.PIPELINE_STAGES:
	set(value):
		type = value
		label.text = Globals.PIPELINE_STAGES.keys()[value]

@export var color: Color = Color.TRANSPARENT:
	set(value):
		color = value
		_update_stage()

@export var container_color: Color = Color.TRANSPARENT:
	set(value):
		container_color = value
		_update_slot_container()

@export var border_color: Color = Color.BLACK:
	set(value):
		border_color = value
		_update_slot_container()

@export var left_border: int = 0:
	set(value):
		left_border = value
		_update_slot_container()

@export var top_border: int = 0:
	set(value):
		top_border = value
		_update_slot_container()

@export var right_border: int = 0:
	set(value):
		right_border = value
		_update_slot_container()

@export var bottom_border: int = 0:
	set(value):
		bottom_border = value
		_update_slot_container()

@export var border_radius: Dictionary = {'Top Left': 0, 'Top Right': 0, 'Bottom Left': 0, 'Bottom Right': 0}:
	set(value):
		border_radius = value
		_update_stage()

func _ready():
	_update_stage()
	_update_slot_container()
	label.text = Globals.PIPELINE_STAGES.keys()[type]
	custom_minimum_size = Vector2(min_size, min_size)

func _update_stage():
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = container_color
	stylebox.corner_radius_top_left = border_radius['Top Left']
	stylebox.corner_radius_top_right = border_radius['Top Right']
	stylebox.corner_radius_bottom_right = border_radius['Bottom Right']
	stylebox.corner_radius_bottom_left = border_radius['Bottom Left']
	
	stageContainer.add_theme_stylebox_override('panel', stylebox)

func _update_slot_container():
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = container_color 
	stylebox.border_width_left = left_border
	stylebox.border_width_top = top_border
	stylebox.border_width_right = right_border
	stylebox.border_width_bottom = bottom_border
	stylebox.border_color = border_color
	
	slotContainer.add_theme_stylebox_override('panel', stylebox)

func set_instruction(inst: Instruction, color: Color = Color.TRANSPARENT):
	slot.set_instruction(inst, color)

func get_color() -> Color:
	return slot.get_color()

func get_instruction() -> Instruction:
	return slot.get_instruction()

func clear_instruction():
	slot.clear_instruction()

func clear():
	color = Color.TRANSPARENT
	container_color = Color.TRANSPARENT
