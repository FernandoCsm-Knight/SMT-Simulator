extends Object
class_name ThreadInstructions

var instruction_set: Array[Instruction] = []
var thread_id: int: get = get_thread_id

func _init(instructions: Array[Instruction]) -> void:
	self.thread_id = ResourceUID.create_id()
	
	for inst in instructions:
		inst.set_thread_id(thread_id)
		self.instruction_set.append(inst)

func get_thread_id() -> int:
	return thread_id

func append(instruction: Instruction):
	self.instruction_set.append(instruction)

func remove(instruction: Instruction) -> bool:
	for i in range(instruction_set.size()):
		if instruction_set[i].id == instruction.id:
			instruction_set.remove_at(i)
			return true
	return false

func remove_at(position: int):
	instruction_set.remove_at(position)

func has_instructions() -> bool:
	return instruction_set.size() > 0

func size() -> int:
	return instruction_set.size()

func duplicate() -> ThreadInstructions:
	return ThreadInstructions.new(instruction_set)

func get_dependencies_for(index: int) -> Dictionary:
	var curr: Instruction = instruction_set[index]
	var other: Instruction
	var dependencies = {
		Globals.DEPENDENCIES.RAW: [],
		Globals.DEPENDENCIES.WAW: [],
		Globals.DEPENDENCIES.WAR: []
	}
	
	for i in range(index):
		other = instruction_set[i]
		
		if other.write_reg == curr.op1_reg or other.write_reg == curr.op2_reg:
			dependencies[Globals.DEPENDENCIES.RAW].append(Dependency.new(
				other, curr, other.write_reg, i, index, Globals.DEPENDENCIES.RAW
			))
		
		if other.write_reg == curr.write_reg:
			dependencies[Globals.DEPENDENCIES.WAW].append(Dependency.new(
				other, curr, other.write_reg, i, index, Globals.DEPENDENCIES.WAW
			))
	
		if other.op1_reg == curr.write_reg or other.op2_reg == curr.write_reg:
			dependencies[Globals.DEPENDENCIES.WAR].append(Dependency.new(
				other, curr, curr.write_reg, i, index, Globals.DEPENDENCIES.WAR
			))
	
	return dependencies

func get_dependencies() -> Dictionary:
	var curr: Instruction
	var other: Instruction
	var dependencies = {
		Globals.DEPENDENCIES.RAW: [],
		Globals.DEPENDENCIES.WAW: [],
		Globals.DEPENDENCIES.WAR: []
	}
	
	for i in range(instruction_set.size()):
		for j in range(i):
			curr = instruction_set[i]
			other = instruction_set[j]
			
			if other.write_reg == curr.op1_reg or other.write_reg == curr.op2_reg:
				dependencies[Globals.DEPENDENCIES.RAW].append(Dependency.new(
					other, curr, other.write_reg, j, i, Globals.DEPENDENCIES.RAW
				))
			
			if other.write_reg == curr.write_reg:
				dependencies[Globals.DEPENDENCIES.WAW].append(Dependency.new(
					other, curr, other.write_reg, j, i, Globals.DEPENDENCIES.WAW
				))

			if other.op1_reg == curr.write_reg or other.op2_reg == curr.write_reg:
				dependencies[Globals.DEPENDENCIES.WAR].append(Dependency.new(
					other, curr, curr.write_reg, j, i, Globals.DEPENDENCIES.WAR
				))
				
	return dependencies
