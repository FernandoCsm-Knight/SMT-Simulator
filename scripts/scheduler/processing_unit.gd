extends Object
class_name ProcessingUnit

var instruction_fetch_range: int # TODO: implementar a opção de selecionar o range no app
var clock_range: int
var thread_pool: Array[ThreadInstructions]
var units_manager: UnitsManager

func _init(instruction_fetch_range: int, clock_range: int) -> void:
	self.instruction_fetch_range = instruction_fetch_range
	self.clock_range = clock_range
	self.units_manager = UnitsManager.new()

func append_execution_unit(unit: Globals.EXECUTION_UNIT):
	units_manager.append(unit)

func remove_execution_unit(unit: Globals.EXECUTION_UNIT):
	units_manager.remove(unit)

func append_thread(thread: ThreadInstructions):
	thread_pool.append(thread)

func remove_thread(thread_id: int) -> bool:
	for i in range(thread_pool.size()):
		if thread_pool[i].thread_id == thread_id:
			thread_pool.remove_at(i)
			return true
	
	return false
