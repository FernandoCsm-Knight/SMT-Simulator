extends Control
class_name Displayer

@export var animation: AnimationPlayer = null
@export var info_box: Container = null
@export var metrics: DisplayerMetrics = null

var mouse_in: bool = false

signal forwarding_request(value: bool)

func _ready() -> void:
	info_box.hide()
	info_box.mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_cpi(cpi: float):
	metrics.set_cpi(cpi)

func set_ipc(ipc: float):
	metrics.set_ipc(ipc)

func set_usage(usage: float):
	metrics.set_usage(usage)

func set_stalls(stalls: int):
	metrics.set_stalls(stalls)

func set_cycles(cycles: int):
	metrics.set_cycles(cycles)

func set_architecture(architecture: Globals.ARCHITECTURE):
	metrics.set_architecture(architecture)

func set_thread_support(policy: Globals.POLICIES):
	metrics.set_thread_support(policy)

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
