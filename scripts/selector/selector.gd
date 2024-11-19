@tool
extends Control
class_name Selector

@export var manager: Control = null

signal policy_updated(policy: Policy)

func accomodate_architecture(architecture: Globals.ARCHITECTURE):
	match architecture:
		Globals.ARCHITECTURE.SCALAR:
			manager.enable([Globals.POLICIES.IMT, Globals.POLICIES.BMT])
		Globals.ARCHITECTURE.SUPER:
			manager.enable([Globals.POLICIES.IMT, Globals.POLICIES.BMT, Globals.POLICIES.SMT])
		_:
			pass

func notify_policy(policy: Policy):
	policy_updated.emit(policy)
	
