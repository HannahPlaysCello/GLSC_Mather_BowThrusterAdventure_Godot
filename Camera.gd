extends Camera2D

@export var target: Node2D  # drag your ship here in the editor

func _process(_delta):
	if target:
		global_position = target.global_position
