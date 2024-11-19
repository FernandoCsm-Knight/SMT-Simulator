extends Panel

func _ready() -> void:
	for i in range(10):
		print(ResourceUID.create_id())
