@tool
extends Label

@export var parent: Control 

func _ready() -> void:
	if parent.has_signal('text_updated'):
		parent.text_updated.connect(_on_text_updated)

func _on_text_updated(value):
	self.text = value
	
