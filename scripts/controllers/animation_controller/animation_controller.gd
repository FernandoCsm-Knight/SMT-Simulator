extends Control
class_name AnimationController

var holding: bool = false
var toggled: bool = false
var distance: Vector2 = Vector2()

@export var previous_button: Button = null
@export var play_button: Button = null
@export var next_button: Button = null

signal previous_step_pressed
signal next_step_pressed
signal play_pressed(is_play: bool)

var pause_icon = preload("res://icons/HugeiconsPause.svg")
var play_icon = preload("res://icons/TablerPlay.svg")

func update_step_buttons(can_go_previous: bool, can_go_next: bool):
	next_button.disabled = not can_go_next
	play_button.disabled = not can_go_next
	previous_button.disabled = not can_go_previous
	
	if play_button.disabled:
		play_button.icon = play_icon
		toggled = false

func _physics_process(delta: float) -> void:
	if holding:
		var target_pos = get_global_mouse_position() + distance
		var viewport_rect = get_viewport_rect()
		var parent_rect = get_parent().get_global_rect() if get_parent() is Control else viewport_rect
		
		target_pos.x = clamp(target_pos.x, viewport_rect.position.x, viewport_rect.end.x - size.x)
		target_pos.y = clamp(target_pos.y, viewport_rect.position.y, viewport_rect.end.y - size.y)
		
		target_pos.x = clamp(target_pos.x, parent_rect.position.x, parent_rect.end.x - size.x)
		target_pos.y = clamp(target_pos.y, parent_rect.position.y, parent_rect.end.y - size.y)
		
		global_position = lerp(global_position, target_pos, 25 * delta)

func _on_holder_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		holding = event.is_pressed()
		if holding:
			distance = global_position - get_viewport().get_mouse_position()

func _on_previous_pressed() -> void:
	previous_step_pressed.emit()

func _on_next_pressed() -> void:
	next_step_pressed.emit()

func _on_play_pressed() -> void:
	play_button.icon = play_icon if toggled else pause_icon
	toggled = not toggled
	play_pressed.emit(toggled)
