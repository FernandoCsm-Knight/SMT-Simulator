extends Control

@export var animation: AnimationPlayer : set = set_animation

signal animation_updated(value)

func _ready() -> void:
	set_animation(animation)

func set_animation(value):
	animation = value
	animation_updated.emit(value)
