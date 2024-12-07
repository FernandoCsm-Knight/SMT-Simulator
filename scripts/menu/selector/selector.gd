@tool
extends Control
class_name Selector

@export var manager: ItemManager = null
@export var default_policy: Globals.POLICIES = Globals.POLICIES.NONE: 
	set = set_policy_type, 
	get = get_policy_type

signal policy_updated(policy: Policy)

func _ready() -> void:
	set_policy_type(default_policy)

func accomodate_architecture(architecture: Globals.ARCHITECTURE):
	manager.enable(architecture)

func set_policy_type(policy: Globals.POLICIES):
	manager.accomodate_policy(policy)
	default_policy = policy

func get_policy_type() -> Globals.POLICIES:
	return default_policy

func get_policy() -> Policy:
	return manager.current_policy

func notify_policy(policy: Policy):
	policy_updated.emit(policy)
