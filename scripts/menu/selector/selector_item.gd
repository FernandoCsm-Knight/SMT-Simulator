@tool
extends Control
class_name SelectorItem

@export var type: Globals.POLICIES = Globals.POLICIES.NONE: set = set_type, get = get_type
@export var policy: Policy = null: set = set_policy, get = get_policy

@export var checkbox: CheckBox 
@export var label: Label 

signal policy_selected(policy: Policy)

func _ready() -> void:
	if not checkbox.toggled.is_connected(_on_checkbox_toggled):
		checkbox.toggled.connect(_on_checkbox_toggled)
	label.text = _get_enum_name(type)

func set_type(value: Globals.POLICIES) -> void:
	type = value
	label.text = _get_enum_name(type)

func get_type() -> Globals.POLICIES:
	return type

func set_policy(value: Policy):
	if value == null:
		value = Policy.new()
	
	policy = value

func get_policy() -> Policy:
	return policy

func reset(value: bool):
	if checkbox.toggled.is_connected(_on_checkbox_toggled): 
		checkbox.toggled.disconnect(_on_checkbox_toggled)
	checkbox.set_pressed(value)
	checkbox.toggled.connect(_on_checkbox_toggled)

func _on_checkbox_toggled(is_pressed: bool):
	policy_selected.emit(policy if is_pressed else Policy.new())

func _get_enum_name(value) -> String:
	if value == Globals.POLICIES.STD_SCALAR or value == Globals.POLICIES.STD_SUPERSCALAR:
		return 'STD'
	
	var index = Globals.POLICIES.values().find(value)
	if index != -1:
		return Globals.POLICIES.keys()[index]
	return Globals.POLICIES.keys()[0]
