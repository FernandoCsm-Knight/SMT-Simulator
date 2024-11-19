@tool
extends Control
class_name SelectorItem

@export var type: Globals.POLICIES: set = set_type, get = get_type
@export var policy: Policy: set = set_policy, get = get_policy

@export var checkbox: CheckBox 
@export var label: Label 

signal policy_selected(policy: Policy)

func _ready() -> void:	
	checkbox.toggled.connect(_on_checkbox_toggled)
	label.text = _get_enum_name(Globals.POLICIES, type)

func set_type(value: Globals.POLICIES) -> void:
	type = value
	label.text = _get_enum_name(Globals.POLICIES, type)

func get_type() -> Globals.POLICIES:
	return type

func set_policy(value: Policy):
	policy = value

func get_policy() -> Policy:
	return policy

func reset(value: bool):
	checkbox.toggled.disconnect(_on_checkbox_toggled)
	checkbox.set_pressed(value)
	checkbox.toggled.connect(_on_checkbox_toggled)

func _on_checkbox_toggled(is_pressed: bool):
	policy_selected.emit(policy if is_pressed else Policy.new())

func _get_enum_name(enum_dict, value):
	var index = enum_dict.values().find(value)
	if index != -1:
		return enum_dict.keys()[index]
	return enum_dict.keys()[0]
