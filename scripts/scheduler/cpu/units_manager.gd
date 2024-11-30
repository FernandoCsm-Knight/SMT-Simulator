extends Object
class_name UnitsManager

var number_of_units: int: get = get_number_of_units
var all_units: Dictionary = {}
var units_in_use: Dictionary = {}

func _init() -> void:
	for key in Globals.EXECUTION_UNIT.values():
		all_units[key] = 0
		units_in_use[key] = 0

func get_number_of_units() -> int:
	return number_of_units

func append(unit: Globals.EXECUTION_UNIT):
	all_units[unit] += 1
	number_of_units += 1

func remove(unit: Globals.EXECUTION_UNIT) -> bool:
	var response: bool = is_unit_available(unit)
	
	if response:
		all_units[unit] -= 1
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

func is_unit_available(unit: Globals.EXECUTION_UNIT) -> bool:
	return units_in_use[unit] < all_units[unit]

func clear():
	for key in Globals.EXECUTION_UNIT.values():
		all_units[key] = 0
		units_in_use[key] = 0
