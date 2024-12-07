@tool
extends HBoxContainer
class_name ItemManager

var current_policy: Policy 
@export var selector: Selector = null

func _ready():
	for child in get_children():
		if child is SelectorItem:
			child.policy_selected.connect(_on_policy_selected)
	
	selector.notify_policy(current_policy)

func accomodate_policy(policy_type: Globals.POLICIES):
	var found: bool = false
	var there_is: bool = false
	for child in get_children():
		if child is SelectorItem:
			there_is = child.get_type() == policy_type
			if there_is: 
				current_policy = child.get_policy()
				found = true
			child.reset(there_is)
	
	if not found: current_policy = Policy.new()

func _on_policy_selected(policy: Policy):
	for child in get_children():
		if child is SelectorItem and child.get_policy() != policy: child.reset(false)
	
	current_policy = policy
	selector.notify_policy(policy)

func enable(architecture: Globals.ARCHITECTURE):
	for child in get_children():
		if child is SelectorItem:
			if child.get_policy().support(architecture):
				child.show()
				child.mouse_filter = Control.MOUSE_FILTER_STOP
			else:
				child.hide()
				child.mouse_filter = Control.MOUSE_FILTER_IGNORE
