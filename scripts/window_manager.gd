@tool
extends VBoxContainer

@export var menu: Control = null
@export var selector: Selector = null
@export var controller: ScalingController = null

func _ready() -> void:
	pass

func _on_side_bar_architecture_changed(architecture: Globals.ARCHITECTURE) -> void:
	selector.accomodate_architecture(architecture)
	controller.accomodate_architecture(architecture)

func _on_selector_policy_updated(policy: Policy) -> void:
	controller.accomodate_policy(policy)
