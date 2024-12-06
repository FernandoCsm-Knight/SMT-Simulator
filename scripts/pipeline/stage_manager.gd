extends HBoxContainer
class_name StageManager

var stalls: Dictionary
var last_instruction: Instruction
var pipeline_stages: Array[PipelineStage] = []
var current_instruction: int = 0

func _ready() -> void:
	pipeline_stages.resize(Globals.PIPELINE_STAGES.size())
	
	for child in get_children():
		if child is PipelineStage:
			pipeline_stages[child.type] = child

func get_stage(stage: Globals.PIPELINE_STAGES) -> PipelineStage:
	return pipeline_stages[stage]

func pipeline_size() -> int:
	return pipeline_stages.size()

func forward_stall():
	if current_instruction == pipeline_stages.size():
		current_instruction -= 1
	
	for i in range(current_instruction, Globals.PIPELINE_STAGES.EX, -1):
		pipeline_stages[i].set_instruction(
			pipeline_stages[i - 1].get_instruction(),
			pipeline_stages[i - 1].get_color() 
		)
	
	pipeline_stages[2].set_instruction(Instruction.new())
	current_instruction += 1

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

func backward_stall(instruction: Instruction = null, color: Color = Color.TRANSPARENT):
	var i: int = Globals.PIPELINE_STAGES.EX
	while i < current_instruction - 1:
		pipeline_stages[i].set_instruction(
			pipeline_stages[i + 1].get_instruction(),
			pipeline_stages[i + 1].get_color()
		)
		i += 1
	
	pipeline_stages[current_instruction - 1].set_instruction(instruction, color)
	if instruction == null: current_instruction -= 1

func backward(instruction: Instruction = null, color: Color = Color.TRANSPARENT):
	for i in range(current_instruction - 1):
		pipeline_stages[i].set_instruction(
			pipeline_stages[i + 1].get_instruction(),
			pipeline_stages[i + 1].get_color()
		)
	
	pipeline_stages[current_instruction - 1].set_instruction(instruction, color)
	if instruction == null: current_instruction -= 1

func reset_state():
	current_instruction = 0
	for stage in pipeline_stages:
		stage.clear_instruction()
