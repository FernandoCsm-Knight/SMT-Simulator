extends Control
class_name ScalingController

@export var drawing_area: Panel = null

func accomodate_architecture(architecture: Globals.ARCHITECTURE):
	drawing_area.configure_architecture(architecture)

func accomodate_policy(policy: Policy):
	drawing_area.configure_policy(policy)
