@tool
extends Panel

@export var parent: Control 

var style: StyleBoxFlat = self.get_theme_stylebox('panel').duplicate()

func _ready() -> void:
	if parent.has_signal('background_updated'):
		parent.background_updated.connect(_on_background_updated)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			parent.handle_click()

func _on_background_updated(is_selected):
	style.set('bg_color', Color(0, 0, 0, 1) if is_selected else Color(1, 1, 1, 0))
	add_theme_stylebox_override('panel', style)
