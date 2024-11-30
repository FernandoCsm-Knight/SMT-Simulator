@tool
extends Control
class_name Selector

@export var manager: Control = null
@export var default_policy: Globals.POLICIES = Globals.POLICIES.NONE : set = set_policy

signal policy_updated(policy: Policy)

func _ready() -> void:
	set_policy(default_policy)

func accomodate_architecture(architecture: Globals.ARCHITECTURE):
	match architecture:
		Globals.ARCHITECTURE.SCALAR:
			manager.enable([Globals.POLICIES.IMT, Globals.POLICIES.BMT])
		Globals.ARCHITECTURE.SUPER:
			manager.enable([Globals.POLICIES.IMT, Globals.POLICIES.BMT, Globals.POLICIES.SMT])
		_:
			pass

func set_policy(policy: Globals.POLICIES):
	manager.accomodate_policy(policy)
	default_policy = policy

func notify_policy(policy: Policy):
	policy_updated.emit(policy)
