extends Object
class_name InstructionParser

var instructions_map: Dictionary = {}

var thread_instructions: Dictionary = {}
var labels_by_thread: Dictionary = {}

func _init(file_path: String):
	var found_thread: bool = false
	var temp_instructions: Array[Instruction] = []
	var temp_labels: Dictionary = {}
	var current_thread: int = 0
	
	for i in range(Globals.INSTRUCTIONS.size()):
		instructions_map[Globals.INSTRUCTIONS.keys()[i]] = Globals.INSTRUCTIONS.values()[i]
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Não foi possível abrir o arquivo: " + file_path)
		return

	var line_count: int = 0
	while file.get_position() < file.get_length():
		var line: String = file.get_line().strip_edges()
		line_count += 1
		if line == "":
			continue

		if line.to_lower().begins_with("thread "):
			var parts: PackedStringArray = line.split(" ", false)
			if parts.size() < 2:
				push_error("Erro de parsing na linha %d: '%s'" % [line_count, line])
				return

			var thread_id_str: String = parts[1].replace(":", "")
			var thread_id: int = thread_id_str.to_int()
			if thread_id == 0 and thread_id_str != "0":
				push_error("ID da thread inválido na linha %d: '%s'" % [line_count, line])
				return

			found_thread = true
			current_thread = thread_id
			thread_instructions[current_thread] = []
			labels_by_thread[current_thread] = {}
			continue

		if found_thread:
			# Já temos threads definidas
			if current_thread == 0:
				push_error("Instrução/Label fora de qualquer thread na linha %d: '%s'" % [line_count, line])
				return

			# Checa se é label
			if line.ends_with(":"):
				var label_name: String = line.substr(0, line.length()-1).strip_edges().to_upper()
				if label_name == "":
					push_error("Label inválido na linha %d." % [line_count])
					return
				var next_index: int = thread_instructions[current_thread].size()
				labels_by_thread[current_thread][label_name] = next_index
				continue

			# Caso contrário, é uma instrução
			var instr: Instruction = parse_instruction_line(line, line_count)
			if instr == null:
				return
			instr.set_thread_id(current_thread)
			thread_instructions[current_thread].append(instr)

		else:
			# Nenhuma thread encontrada ainda
			if line.ends_with(":"):
				var label_name_nothread: String = line.substr(0, line.length()-1).strip_edges().to_upper()
				if label_name_nothread == "":
					push_error("Label inválido na linha %d." % [line_count])
					return
				var next_index_nothread: int = temp_instructions.size()
				temp_labels[label_name_nothread] = next_index_nothread
				continue

			var instr_nothread: Instruction = parse_instruction_line(line, line_count)
			if instr_nothread == null:
				return
			instr_nothread.set_thread_id(1) # se não tem threads, assume thread 1
			temp_instructions.append(instr_nothread)

	file.close()

	# Se nenhuma thread foi encontrada, tudo vai para a thread 1
	if not found_thread:
		thread_instructions[1] = temp_instructions
		labels_by_thread[1] = temp_labels

	# Resolve labels
	for t_id in thread_instructions.keys():
		resolve_labels(thread_instructions[t_id], labels_by_thread[t_id])

func parse_instruction_line(line: String, line_count: int) -> Instruction:
	# Exemplo de linha:
	# Instrução de cálculo: "ADD, R1, R2, R3"
	# Instrução de controle: "BEQ, R1, R2, LABEL"

	var parts: Array[String] = []
	for p in line.split(","):
		parts.append(p.strip_edges())

	if parts.size() < 4:
		push_error("Erro de parsing na linha %d: '%s'. Formato inválido." % [line_count, line])
		return null

	var instr_str: String = parts[0].to_upper()

	if not instructions_map.has(instr_str):
		push_error("Instrução não reconhecida na linha %d: %s" % [line_count, instr_str])
		return null

	var instruction_type: int = instructions_map[instr_str]

	var write_reg: String = ""
	var op1_reg: String = ""
	var op2_reg: String = ""
	var branch_target: String = ""

	# Se a instrução é de controle (por exemplo, BEQ, BNE, JAL),
	# ela não deve ter um registrador de escrita. Ao invés disso,
	# o primeiro registrador lido será op1_reg, o segundo será op2_reg
	# e o terceiro parâmetro será um label de branch.
	if instruction_type in [Globals.INSTRUCTIONS.BEQ, Globals.INSTRUCTIONS.BNE, Globals.INSTRUCTIONS.JAL]:
		# Exemplo: BEQ, R1, R2, LABEL
		op1_reg = parts[1].to_upper()
		op2_reg = parts[2].to_upper()
		branch_target = parts[3].to_upper()
	else:
		# Exemplo: ADD, R1, R2, R3
		write_reg = parts[1].to_upper()
		op1_reg = parts[2].to_upper()
		op2_reg = parts[3].to_upper()

	var instr: Instruction = Instruction.new(instruction_type, write_reg, op1_reg, op2_reg, branch_target)
	return instr

func resolve_labels(instructions: Array, label_dict: Dictionary) -> void:
	for instr: Instruction in instructions:
		if instr.branch_target_label != "":
			var label: String = instr.branch_target_label.to_upper()
			if not label_dict.has(label):
				push_error("Label '%s' não encontrado na mesma thread." % [label])
				return
			instr.branch_target_index = label_dict[label]

func get_thread_instructions() -> Dictionary:
	return thread_instructions

func print_instructions() -> void:
	for t_id in thread_instructions.keys():
		print("Thread %d:" % [t_id])
		var instr_list: Array = thread_instructions[t_id]
		for i in range(instr_list.size()):
			var instr: Instruction = instr_list[i]
			print("%d: %s" % [i, instr.to_string()])
