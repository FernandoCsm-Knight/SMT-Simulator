extends Control
class_name DisplayerMetrics

@export var subtitle: DisplayerSubtitle = null

@export var cpi_label: Label = null
@export var ipc_label: Label = null
@export var usage_label: Label = null
@export var stalls_label: Label = null
@export var cycles_label: Label = null

func set_cpi(cpi: float):
	if cpi_label != null:
		cpi_label.text = 'CPI: %.*f' % [2, cpi]

func set_ipc(ipc: float):
	if ipc_label != null:
		ipc_label.text = 'IPC: %.*f' % [2, ipc]

func set_usage(usage: float):
	if usage_label != null:
		usage_label.text = 'Usage: %.*f' % [2, usage]

func set_stalls(stalls: int):
	if stalls_label != null:
		stalls_label.text = 'Stalls: {}'.format([stalls], '{}')

func set_cycles(cycles: int):
	if cycles_label != null:
		cycles_label.text = 'Cycles: {}'.format([cycles], '{}')

func set_architecture(architecture: Globals.ARCHITECTURE):
	subtitle.set_architecture(architecture)

func set_thread_support(policy: Globals.POLICIES):
	subtitle.set_thread_support(policy)
