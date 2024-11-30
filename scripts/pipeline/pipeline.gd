extends Control
class_name Pipeline

var current_processor: Processor = null: set = reset_state
var scheduled_instructions: Array = []
var animation_index: int = 0
@export var manager: StageManager = null

func can_go_next() -> bool:
	return animation_index < scheduled_instructions.size()

func can_go_prev() -> bool:
	return animation_index > 0

func forward():
	var instruction: Instruction = scheduled_instructions[animation_index][0]
	print(current_processor._thread_colors)
	print(instruction.get_thread_id())
	print(current_processor.get_thread_color(instruction.get_thread_id()))
	manager.forward(instruction, current_processor.get_thread_color(instruction.get_thread_id()))
	animation_index += 1

func backward():
	if animation_index <= manager.pipeline_stages.size():
		manager.backward()
	else:
		var index: int = animation_index - manager.pipeline_stages.size() - 1
		var instruction: Instruction = scheduled_instructions[index][0]
		manager.backward(instruction, current_processor.get_thread_color(instruction.get_thread_id()))
	animation_index -= 1

func reset_state(processor: Processor) -> void:
	current_processor = processor
	if not processor.is_empty():
		scheduled_instructions = processor.process_instructions()
		animation_index = 0
	manager.reset_state()
