@tool
extends VBoxContainer

@export var sidebar: Control
var current_item: SideBarItem = null

func _ready():
	if sidebar.has_signal('architecture_updated'):
		sidebar.architecture_updated.connect(update_architecture)
	
	for child in get_children():
		if child is SideBarItem:
			child.item_clicked.connect(_on_item_clicked)

func update_architecture(value: Globals.ARCHITECTURE):
	for child in get_children():
		if child is SideBarItem and child.get_architecture() == value:
			_on_item_clicked(child)

func _on_item_clicked(item: SideBarItem):
	if current_item != item:
		item.set_selected(true)
		if current_item != null:
			current_item.set_selected(false)
		current_item = item
		
		sidebar.set_architecture(item.get_architecture())
