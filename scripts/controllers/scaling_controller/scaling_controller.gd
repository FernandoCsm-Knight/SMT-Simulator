extends Control
class_name ScalingController

@export var architecture_controller: ArchitectureController = null
@export var animation_controller: AnimationController = null

func accomodate_processor(processor_architecture: Processor):
	architecture_controller.configure_processor(processor_architecture)

func _on_animation_controller_next_step_pressed() -> void:	
	architecture_controller.next_step()

func _on_animation_controller_play_pressed(is_play: bool) -> void:
	print(is_play)

func _on_animation_controller_previous_step_pressed() -> void:
	architecture_controller.previous_step()

func _on_architecture_controller_step_state_changed(can_go_previous: bool, can_go_next: bool) -> void:
	animation_controller.update_step_buttons(can_go_previous, can_go_next)
