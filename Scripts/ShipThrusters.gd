extends CharacterBody2D
@onready var animated_ship = $AnimatedSprite2D
@export var tilemap: TileMapLayer

#forward motion
var speed = 100.0 #max forward movement speed
var acceleration: float = 100.0
var deceleration: float = 80.0
var current_speed: float = 0.0 
var is_moving_forward: bool = false

# turning
var turn_speed = 0.8 #max turn speed
var turn_acceleration: float = 1.0
var turn_deceleration: float = 0.5
var current_turn_speed: float = 0.0
var current_turn_velocity: float = 0.0 #negative is left, positive is right

#thruster movement
var lateral_speed = 100.0 #max sideways vel
var lateral_acceleration = 50.0
var lateral_deceleration = 80.0
var current_lateral_speed = 0.0

#logic
var scene 
var challenge_mode = null
var practice_mode = null

@warning_ignore("UNUSED_SIGNAL")
signal collision_happened

func _ready():
	set_physics_process(true)
	scene = get_root_scene()
	if scene == "ChallengeMode":
		challenge_mode = get_parent()  #this should be ChallengeMode
		if not challenge_mode.has_method("advance_challenge_phase"):
			print("parent not challege mode")
			challenge_mode = null
	elif scene == "PracticeMode":
		practice_mode = get_parent()
		if not practice_mode.has_method("end_game"):
			print("parent not practice mode")
			practice_mode = null

func get_root_scene():
	var node = self
	while node.get_parent() != null:  #move up the scene tree
		node = node.get_parent()
		if node.name == "PracticeMode":
			return "PracticeMode"
		elif node.name == "ChallengeMode":
			return "ChallengeMode"
	print("error")
	return "Unknown"

func _process(delta: float) -> void:
	var parent = get_parent()
	if parent.has_method("get") and parent.get("waiting_for_key_release"):
		return
		
	#animated sprite default motion
	animated_ship.play("MatherV0.3")
	
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
	
	#thrusters
	var lateral_input: int = 0
	if Input.is_action_pressed("thruster_left"):
		lateral_input = 1
	elif Input.is_action_pressed("thruster_right"):
		lateral_input = -1
	
	if lateral_input != 0:
		current_lateral_speed = move_toward(current_lateral_speed, lateral_input * lateral_speed, lateral_acceleration * delta)
	else:
		current_lateral_speed = move_toward(current_lateral_speed, 0, lateral_deceleration * delta)
	
	#calc vectors
	var forward_vector = Vector2.RIGHT.rotated(rotation)
	var right_vector = Vector2(forward_vector.y, -forward_vector.x)

	#apply
	velocity = forward_vector * current_speed + right_vector * current_lateral_speed
	move_and_slide()
	
	#detect collisions
	if velocity.length() > 0: 
		var collision = get_last_slide_collision()
		if collision and not GameState.is_colliding:
			if scene == "ChallengeMode":
				GameState.collision_count += 1
			elif scene == "PracticeMode":
				emit_signal("collision_happened")
			GameState.is_colliding = true
		elif not collision:
			GameState.is_colliding = false
	
	#detect end tiles
	if check_if_on_goal_tile():
		velocity = Vector2.ZERO
		is_moving_forward = false
		move_and_slide()

		if scene == "PracticeMode": 
			practice_mode.end_game()
		if scene == "ChallengeMode":
			challenge_mode.advance_challenge_phase()
		
func check_if_on_goal_tile():
	if not tilemap:
		return false  #prevent errors if no map
		
	var collision_shape = $CollisionPolygon2D
	var transformed_points = []

	for point in collision_shape.polygon:
		var world_point = to_global(point)  #world pos
		var tile_pos = tilemap.local_to_map(world_point)  #tilemap position
		transformed_points.append(tile_pos)

	for tile_pos in transformed_points:
		var tile_data = tilemap.get_cell_tile_data(tile_pos) #this is for any part of ship on goal tile
		if tile_data and tile_data.get_custom_data("is_end_tile"):
			return true 
	
	return false
