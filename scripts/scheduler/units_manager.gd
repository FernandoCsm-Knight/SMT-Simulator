extends Object
class_name UnitsManager

var number_of_units: int: get = get_number_of_units
var all_units: Dictionary = {}
var units_in_use: Dictionary = {}
var columns_units_values: Array[Globals.EXECUTION_UNIT] = []
var columns_already_used: Array[bool] = []

func _init() -> void:
	for key in Globals.EXECUTION_UNIT.values():
		all_units[key] = 0
		units_in_use[key] = 0

func get_number_of_units() -> int:
	return number_of_units

func append(unit: Globals.EXECUTION_UNIT):
	all_units[unit] += 1
	columns_units_values.append(unit)
	columns_already_used.append(false)
	number_of_units += 1

func remove(unit: Globals.EXECUTION_UNIT) -> bool:
	var response: bool = is_unit_available(unit)
	
	if response:
		all_units[unit] -= 1
		var idx: int = columns_units_values.find(unit)
		columns_units_values.remove_at(idx)
		columns_already_used.remove_at(idx)
		number_of_units -= 1
		
	return response

func free_unit(unit: Globals.EXECUTION_UNIT) -> bool:
	var response: bool = has_any_in_use(unit) 
	if response: units_in_use[unit] -= 1
	return response

func free_all_units():
	for key in Globals.EXECUTION_UNIT.values():
		units_in_use[key] = 0

func use_unit(unit: Globals.EXECUTION_UNIT) -> bool:
	var response: bool = is_unit_available(unit)
	if response: units_in_use[unit] += 1
	return response

func has_any_in_use(unit: Globals.EXECUTION_UNIT) -> bool:
	return units_in_use[unit] > 0

func has_unit_available() -> bool:
	for unit in Globals.EXECUTION_UNIT.values():
		if is_unit_available(unit):
			return true
	
	return false

func get_unit_column(unit: Globals.EXECUTION_UNIT) -> int:
	for i in range(columns_units_values.size()):
		if columns_units_values[i] == unit and not columns_already_used[i]:
			return i
	return -1

func set_unit_column(idx: int) -> bool:
	var response: bool = idx >= 0 and idx < columns_already_used.size()
	if response: columns_already_used[idx] = true
	return response

func reset_columns():
	for i in range(columns_already_used.size()):
		columns_already_used[i] = false

func is_unit_available(unit: Globals.EXECUTION_UNIT) -> bool:
	return units_in_use[unit] < all_units[unit]

func clear():
	columns_units_values.clear()
	columns_already_used.clear()
	for key in Globals.EXECUTION_UNIT.values():
		all_units[key] = 0
		units_in_use[key] = 0
