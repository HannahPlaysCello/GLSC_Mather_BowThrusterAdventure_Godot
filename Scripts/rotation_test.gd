extends Node2D

@export var rotation_step := 11.25  # Degrees per step

func _process(_delta):
	if Input.is_action_just_pressed("rudder_right"):
		rotation_degrees += rotation_step

	if Input.is_action_just_pressed("rudder_left"):
		rotation_degrees -= rotation_step
