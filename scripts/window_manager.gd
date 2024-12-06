@tool
extends VBoxContainer

@export var menu: Control = null
@export var selector: Selector = null
@export var controller: ScalingController = null

var processor: Processor = Processor.new()

func _ready() -> void:
	processor.append_functional_unit(Globals.EXECUTION_UNIT.ALU)
	processor.append_functional_unit(Globals.EXECUTION_UNIT.ALU)
	processor.append_functional_unit(Globals.EXECUTION_UNIT.DATA)
	
	var first_thread: ThreadInstructions = ThreadInstructions.new(
		[
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R1', 'R2', 'R3'),
			Instruction.new(Globals.INSTRUCTIONS.LW, 'R10', 'R11', 'R5'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R5', 'R1', 'R6'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R5', 'R2', 'R3'),
			Instruction.new(Globals.INSTRUCTIONS.MUL, 'R7', 'R4', 'R8'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R2', 'R7', 'R3'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R9', 'R4', 'R10'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R11', 'R4', 'R6')
		]
	)
	
	var second_thread: ThreadInstructions = ThreadInstructions.new(
		[
			Instruction.new(Globals.INSTRUCTIONS.SUB, 'R2', 'R3', 'R4'),
			Instruction.new(Globals.INSTRUCTIONS.LW, 'R0', 'R11', 'R2'),
			Instruction.new(Globals.INSTRUCTIONS.LW, 'R1', 'R11', 'R3'),
			Instruction.new(Globals.INSTRUCTIONS.SLT, 'R0', 'R0', 'R1'),
			Instruction.new(Globals.INSTRUCTIONS.SUB, 'R0', 'R0', 'R0'),
			Instruction.new(Globals.INSTRUCTIONS.ADD, 'R2', 'R0', 'R3')
		]
	)
	
	processor.append_thread(first_thread)
	processor.append_thread(second_thread)
	if not Engine.is_editor_hint():
		controller.accomodate_processor(processor)

func _on_side_bar_architecture_changed(architecture: Globals.ARCHITECTURE) -> void:
	if not Engine.is_editor_hint():
		selector.accomodate_architecture(architecture)
		processor.set_architecture(architecture)
		controller.accomodate_processor(processor)

func _on_selector_policy_updated(policy: Policy) -> void:
	if not Engine.is_editor_hint():
		processor.set_policy(policy)
		controller.accomodate_processor(processor)

func _on_displayer_forwarding_request(has_forwarding: bool) -> void:
	if not Engine.is_editor_hint():
		processor.set_forwarding(has_forwarding)
		controller.accomodate_processor(processor)
