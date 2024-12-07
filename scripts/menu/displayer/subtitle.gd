extends HBoxContainer
class_name DisplayerSubtitle

@export var architecture_label: Label = null
@export var thread_support_label: Label = null

func set_architecture(architecture: Globals.ARCHITECTURE):
	if architecture_label != null:
		architecture_label.text = 'Superscalar' if architecture == Globals.ARCHITECTURE.SUPER else 'Scalar'

func set_thread_support(policy: Globals.POLICIES):
	if thread_support_label != null:
		if policy in [Globals.POLICIES.STD_SCALAR, Globals.POLICIES.STD_SUPERSCALAR]:
			thread_support_label.text = 'Sequential'
		else:
			thread_support_label.text = Globals.POLICIES.keys()[policy]
