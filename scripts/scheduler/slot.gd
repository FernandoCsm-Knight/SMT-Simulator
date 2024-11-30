@tool
extends Control
class_name Slot

@export var panel: Panel = null
@export var label: Label = null
@export var border_size: Dictionary = {'Left': 2, 'Top': 2, 'Right': 2, 'Bottom': 2} : set = set_borders, get = get_border_size
@export var border_color: Color = Color.BLACK : set = set_border_color, get = get_border_color
@export var color: Color : set = set_color, get = get_color
@export var block_size: int : set = set_block_size, get = get_block_size

var instruction: Instruction  = null
var text: String : set = set_text, get = get_text
var font_size: int : set = set_font_size, get = get_font_size
var font_color: Color : set = set_font_color, get = get_font_color

func _ready() -> void:
	label.text = text
	label.add_theme_font_size_override('font_size', font_size)
	label.add_theme_color_override('font_color', font_color)
	custom_minimum_size = Vector2(block_size, block_size)
	_reset_borders()

func _init(
	label_text: String = '', 
	background_color: Color = Color.TRANSPARENT, 
	box_size: int = 30, 
	label_font_size: int = 12, 
	label_font_color: Color = Color.WHITE, 
	border_color: Color = Color.DIM_GRAY,
) -> void:
	set_text(label_text)
	set_color(background_color)
	set_block_size(box_size)
	set_font_size(label_font_size)
	set_font_color(label_font_color)
	set_border_color(border_color)

func _reset_borders():
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = color
	stylebox.border_color = border_color
	stylebox.border_width_left = border_size['Left']
	stylebox.border_width_top = border_size['Top']
	stylebox.border_width_right = border_size['Right']
	stylebox.border_width_bottom = border_size['Bottom']
	panel.add_theme_stylebox_override('panel', stylebox)

func set_instruction(inst: Instruction, color: Color = Color.TRANSPARENT):
	instruction = inst
	if inst == null:
		clear_color()
		clear_text()
	else:
		if inst.operation == Globals.INSTRUCTIONS.STALL:
			clear_text()
		else:
			set_text(Globals.INSTRUCTIONS.keys()[instruction.operation])
		set_color(color)

func get_instruction() -> Instruction:
	return instruction

func set_block_size(box_size: int):
	block_size = box_size
	custom_minimum_size = Vector2(block_size, block_size)

func get_block_size() -> int:
	return block_size

func set_font_size(label_font_size: int) -> void:
	font_size = label_font_size
	if label != null: label.add_theme_font_size_override('font_size', font_size)

func get_font_size() -> int:
	return font_size

func set_text(label_text: String) -> void:
	text = label_text
	if label != null: label.text = text

func get_text() -> String:
	return text

func clear_text() -> void:
	set_text('')

func clear_color() -> void:
	set_color(Color.TRANSPARENT)

func clear_instruction() -> void:
	instruction = null
	clear_text()
	clear_color()

func set_color(background_color: Color) -> void:
	color = background_color
	if panel != null: _reset_borders()

func get_color() -> Color:
	return color

func set_font_color(label_font_color: Color) -> void:
	font_color = label_font_color
	if label != null: label.add_theme_color_override('font_color', font_color)

func get_font_color() -> Color:
	return font_color

func set_border_color(border_color_set: Color):
	border_color = border_color_set
	if panel != null: _reset_borders()

func get_border_color() -> Color:
	return border_color

func set_border_size(left: int, top: int, right: int, bottom: int):
	border_size['Left'] = left
	border_size['Top'] = top
	border_size['Right'] = right
	border_size['Bottom'] = bottom
	if panel != null: _reset_borders()

func set_borders(borders: Dictionary):
	border_size = borders
	if panel != null: _reset_borders()

func get_border_size() -> Dictionary:
	return border_size
