extends Control
class_name ArchitectureController

@export var table: Table
@export var pipeline: Pipeline

var is_superscalar: bool = false
var current_processor: Processor = null : set = configure_processor

signal step_state_changed(can_go_previous: bool, can_go_next: bool)

func _ready():
	if current_processor != null and not current_processor.is_empty():
		is_superscalar = current_processor.get_architecture() == Globals.ARCHITECTURE.SUPER
		configure_processor(current_processor)
	else:
		_update_button_states()

func _update_interface():
	if is_superscalar:
		pipeline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pipeline.hide()
		table.mouse_filter = Control.MOUSE_FILTER_STOP
		table.show()
		table.reset_state(current_processor)
	else:
		table.mouse_filter = Control.MOUSE_FILTER_IGNORE
		table.hide()
		pipeline.mouse_filter = Control.MOUSE_FILTER_STOP
		pipeline.show()
		pipeline.reset_state(current_processor)

func configure_processor(processor: Processor):
	current_processor = processor
	is_superscalar = current_processor.get_architecture() == Globals.ARCHITECTURE.SUPER
	_update_interface()
	_update_button_states()

func next_step():
	if is_superscalar and table.can_go_next():
		table.forward()
		_update_button_states()
	elif pipeline.can_go_next():
		pipeline.forward()
		_update_button_states()

func previous_step():
	if is_superscalar and table.can_go_prev():
		table.backward()
		_update_button_states()
	elif pipeline.can_go_prev():
		pipeline.backward()
		_update_button_states()

func _update_button_states():
	if is_superscalar: step_state_changed.emit(table.can_go_prev(), table.can_go_next())
	else: step_state_changed.emit(pipeline.can_go_prev(), pipeline.can_go_next())
