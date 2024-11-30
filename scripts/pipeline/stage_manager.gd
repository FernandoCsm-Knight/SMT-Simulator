extends HBoxContainer
class_name StageManager

var pipeline_stages: Array[PipelineStage] = []
var current_instruction: int = 0

func _ready() -> void:
	for child in get_children():
		if child is PipelineStage:
			pipeline_stages.append(child)

func forward(instruction: Instruction, color: Color = Color.TRANSPARENT):
	if current_instruction == pipeline_stages.size():
		current_instruction -= 1
	
	for i in range(current_instruction, 0, -1):
		pipeline_stages[i].set_instruction(
			pipeline_stages[i - 1].get_instruction(),
			pipeline_stages[i - 1].get_color() 
		)
	
	pipeline_stages[0].set_instruction(instruction, color)
	current_instruction += 1

func backward(instruction: Instruction = null, color: Color = Color.TRANSPARENT):
	for i in range(current_instruction - 1):
		pipeline_stages[i].set_instruction(
			pipeline_stages[i + 1].get_instruction(),
			pipeline_stages[i + 1].get_color()
		)
	
	pipeline_stages[current_instruction - 1].set_instruction(instruction, color)
	if instruction == null: current_instruction -= 1

func reset_state():
	for stage in pipeline_stages:
		stage.clear_instruction()
