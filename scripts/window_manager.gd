@tool
extends VBoxContainer

@export var menu: Control = null
@export var selector: Selector = null
@export var displayer: Displayer = null
@export var controller: ScalingController = null
@export var standard_path: String = 'simple.txt' 

var processor: Processor = Processor.new()

func _ready() -> void:
	processor.set_displayer(displayer)
	processor.append_functional_unit(Globals.EXECUTION_UNIT.ALU)
	processor.append_functional_unit(Globals.EXECUTION_UNIT.ALU)
	processor.append_functional_unit(Globals.EXECUTION_UNIT.DATA)
	_on_side_bar_file_selected('res://exemples/' + standard_path)

func _on_side_bar_architecture_changed(architecture: Globals.ARCHITECTURE) -> void:
	if not Engine.is_editor_hint():
		selector.accomodate_architecture(architecture)
		processor.set_architecture(architecture)
		processor.set_policy(selector.get_policy())
		controller.accomodate_processor(processor)

func _on_selector_policy_updated(policy: Policy) -> void:
	if not Engine.is_editor_hint():
		processor.set_policy(policy)
		controller.accomodate_processor(processor)

func _on_displayer_forwarding_request(has_forwarding: bool) -> void:
	if not Engine.is_editor_hint():
		processor.set_forwarding(has_forwarding)
		controller.accomodate_processor(processor)

func _on_side_bar_file_selected(path: String) -> void:
	processor.clear_threads()
	var parser: InstructionParser = InstructionParser.new(path)
	var threads: Dictionary = parser.get_thread_instructions()
	
	for key in threads.keys():
		var instructions: Array[Instruction] 
		for element in threads[key]:
			instructions.append(element as Instruction)
		
		processor.append_thread(ThreadInstructions.new(instructions))
	
	if not Engine.is_editor_hint():
		controller.accomodate_processor(processor)
