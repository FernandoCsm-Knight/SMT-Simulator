extends Control
class_name ArchitectureController

@export var table: Table
@export var pipeline: Pipeline
@export var animation_timer: Timer

var is_superscalar: bool = false
var current_processor: Processor = null : set = configure_processor

signal step_state_changed(can_go_previous: bool, can_go_next: bool)

func _ready():
	if current_processor != null and not current_processor.is_empty():
		is_superscalar = current_processor.get_architecture() == Globals.ARCHITECTURE.SUPER
		configure_processor(current_processor)
	else:
		_update_button_states()

func animate(play: bool):
	if animation_timer:
		if play: animation_timer.start()
		else: animation_timer.stop()

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
	animate(false)
	current_processor = processor
	is_superscalar = current_processor.get_architecture() == Globals.ARCHITECTURE.SUPER
	_update_interface()
	_update_button_states()

func next_step():
	if can_go_next():
		if is_superscalar: table.forward()
		else: pipeline.forward()
		_update_button_states()

func previous_step():
	if can_go_prev():
		if is_superscalar: table.backward()
		else: pipeline.backward()
		_update_button_states()

func can_go_next() -> bool:
	return table.can_go_next() if is_superscalar else pipeline.can_go_next()

func can_go_prev() -> bool:
	return table.can_go_prev() if is_superscalar else pipeline.can_go_prev()

func _update_button_states():
	step_state_changed.emit(can_go_prev(), can_go_next())

func _on_animation_timer_timeout() -> void:
	if can_go_next():
		next_step()
	else: 
		animation_timer.stop()
