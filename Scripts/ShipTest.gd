extends CharacterBody2D

#forward motion
var acceleration: float = 100.0
var deceleration: float = 100.0
var speed = 100.0 #max forward movement speed
var current_speed: float = 0.0 
var is_moving_forward: bool = false

# turning
var turn_speed = 5.0 #max turn speed
var turn_acceleration: float = 1.0
var turn_deceleration: float = 1.0
var current_turn_speed: float = 0.0
var current_turn_velocity: float = 0.0 #negative is left, positive is right

func _process(delta: float) -> void:
	
	#forward motion
	if Input.is_action_just_pressed("move_forward"):
		is_moving_forward = !is_moving_forward
	if is_moving_forward:
		current_speed = move_toward(current_speed, speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0, deceleration * delta)
	
	#rotate
	var turn_input: int = 0
	if Input.is_action_pressed("rudder_left"):
		turn_input = -1
	elif Input.is_action_pressed("rudder_right"):
		turn_input = 1
	
	if turn_input != 0:
		current_turn_velocity = move_toward(current_turn_velocity, turn_input * turn_speed, turn_acceleration * delta)
	else:
		current_turn_velocity = move_toward(current_turn_velocity, 0, turn_deceleration * delta)
	rotation += current_turn_velocity * delta

	#apply
	velocity = Vector2.RIGHT.rotated(rotation) * current_speed
	move_and_slide()
