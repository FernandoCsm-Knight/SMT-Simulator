@tool
extends HBoxContainer

# TODO: select default one at editor
var current_policy: Policy = null

@export var selector: Selector = null

func _ready():
	for child in get_children():
		if child is SelectorItem:
			child.policy_selected.connect(_on_policy_selected)

func _on_policy_selected(policy: Policy):
	for child in get_children():
		if child is SelectorItem and child.get_policy() != policy: child.reset(false)
	
	selector.notify_policy(policy)

func enable(policies):
	for child in get_children():
		if child is SelectorItem:
			if child.get_type() in policies:
				child.show()
			else:
				child.hide()
