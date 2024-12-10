@tool
extends Control
class_name SideBar

@export var default_architecture: Globals.ARCHITECTURE : set = set_default_architecture, get = get_default_architecture
@export var file_dialog: FileDialog = null
@export var manager: Control = null

var file_buttom: SideBarItem = null
var current_architecture: Globals.ARCHITECTURE = default_architecture : set = set_architecture, get = get_architecture

signal architecture_changed(architecture: Globals.ARCHITECTURE)
signal file_selected(path: String)

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

func _on_side_bar_item_item_clicked(value: SideBarItem) -> void:
	file_dialog.show()
	file_buttom = value

func _on_file_dialog_file_selected(path: String) -> void:
	if file_buttom: file_buttom.set_selected(false)
	file_selected.emit(path)

func _on_file_dialog_close_requested() -> void:
	if file_buttom: file_buttom.set_selected(false)
	file_dialog.hide()

func _on_file_dialog_canceled() -> void:
	if file_buttom: file_buttom.set_selected(false)
