extends Button

@export var parent: Control

var animation: AnimationPlayer
var icon_default: Texture = preload("res://icons/JamMenu.svg")
var icon_back: Texture = preload("res://icons/TablerChevronsLeft.svg")

func _ready() -> void:
	if parent.has_signal('animation_updated'):
		parent.animation_updated.connect(_on_animation_updated)

func _on_animation_updated(value):
	animation = value

func _toggled(toggled_on: bool) -> void:
	if(toggled_on): 
		animation.play('open_sidebar')
		self.icon = icon_back
	else: 
		animation.play_backwards('open_sidebar')
		self.icon = icon_default
