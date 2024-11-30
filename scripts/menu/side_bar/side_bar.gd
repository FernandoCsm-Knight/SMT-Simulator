@tool
extends Control
class_name SideBar

@export var default_architecture: Globals.ARCHITECTURE : set = set_default_architecture, get = get_default_architecture
@export var manager: Control = null
var current_architecture: Globals.ARCHITECTURE = default_architecture : set = set_architecture, get = get_architecture

signal architecture_changed(architecture: Globals.ARCHITECTURE)

func _ready() -> void:
	manager.update_architecture(default_architecture)
	architecture_changed.emit(current_architecture)

func set_architecture(architecture: Globals.ARCHITECTURE):
	current_architecture = architecture
	architecture_changed.emit(current_architecture)

func get_architecture() -> Globals.ARCHITECTURE:
	return current_architecture
	
func set_default_architecture(architecture: Globals.ARCHITECTURE):
	default_architecture = architecture
	manager.update_architecture(default_architecture)

func get_default_architecture() -> Globals.ARCHITECTURE:
	return default_architecture
