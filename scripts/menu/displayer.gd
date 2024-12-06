extends Control
class_name Displayer

@export var animation: AnimationPlayer = null
@export var info_box: Container = null

var mouse_in: bool = false

signal forwarding_request(value: bool)

func _ready() -> void:
	info_box.hide()
	info_box.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_radio_buttom_mouse_entered() -> void:
	mouse_in = true
	animation.play('resize_info_panel')

func _on_radio_buttom_mouse_exited() -> void:
	mouse_in = false
	animation.play_backwards('resize_info_panel')

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if mouse_in:
		info_box.show()
		info_box.mouse_filter = Control.MOUSE_FILTER_PASS

func _on_animation_player_animation_started(_anim_name: StringName) -> void:
	if not mouse_in:
		info_box.hide()
		info_box.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_check_button_toggled(toggled_on: bool) -> void:
	forwarding_request.emit(toggled_on)
