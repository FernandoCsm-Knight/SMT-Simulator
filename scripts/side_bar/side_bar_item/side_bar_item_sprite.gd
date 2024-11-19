@tool
extends Sprite2D

@export var parent: Control 

func _ready() -> void:
	if parent.has_signal('texture_updated'):
		parent.texture_updated.connect(_on_texture_updated)

func _on_texture_updated(value):
	self.texture = value
