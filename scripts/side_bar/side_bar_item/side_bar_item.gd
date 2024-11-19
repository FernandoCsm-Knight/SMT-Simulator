@tool
extends Control
class_name SideBarItem

@export var text: String : set = set_text, get = get_text
@export var texture: Texture : set = set_texture, get = get_texture
@export var architecture: Globals.ARCHITECTURE : set = set_architecture, get = get_architecture

var selected: bool = false : set = set_selected, get = is_selected

signal item_clicked(value)
signal text_updated(value)
signal texture_updated(value)
signal background_updated(value)

func _ready() -> void:
	text_updated.emit(text)
	texture_updated.emit(texture)
	background_updated.emit(selected)

func handle_click():
	if not selected:
		selected = true
		item_clicked.emit(self)

func set_text(value):
	text = value
	text_updated.emit(value)

func get_text() -> String:
	return text

func set_texture(value):
	texture = value
	texture_updated.emit(value)

func get_texture() -> Texture:
	return texture

func set_selected(value: bool):
	selected = value
	background_updated.emit(value)

func is_selected() -> bool:
	return selected 

func set_architecture(value: Globals.ARCHITECTURE):
	architecture = value

func get_architecture() -> Globals.ARCHITECTURE:
	return architecture
