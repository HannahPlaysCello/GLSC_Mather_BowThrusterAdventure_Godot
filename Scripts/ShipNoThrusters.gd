extends CharacterBody2D
@onready var animated_ship = $AnimatedSprite2D
@export var tilemap: TileMapLayer

#forward motion
var speed = 100.0 #max forward movement speed
var acceleration: float = 100.0
var deceleration: float = 80.0
var current_speed: float = 0.0 
var is_moving_forward: bool = false

#turning
var turn_speed = 0.8 #multiplier for turning speed based on encoder
var turn_acceleration: float = 0.5
var turn_deceleration: float = 5.0 
var current_turn_velocity: float = 0.0  #negative is left, positive is right

#compass
@warning_ignore("unused_signal")
signal heading_changed(new_heading: float)
var last_heading = 0.0 

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
		challenge_mode = get_parent()  #should be ChallengeMode!
		if not challenge_mode.has_method("advance_challenge_phase"):
			print("parent not challenge mode")
			challenge_mode = null
	elif scene == "PracticeMode":
		practice_mode = get_parent()
		if not practice_mode.has_method("end_game"):
			print("parent not practice mode")
			practice_mode = null

func get_root_scene():
	var node = self
	while node.get_parent() != null:
		node = node.get_parent()
		if node.name == "PracticeMode":
			return "PracticeMode"
		elif node.name == "ChallengeMode":
			return "ChallengeMode"
	print("error could not determine root scene")
	return "Unknown"

#use _physics_process for physics/movement updates
func _physics_process(delta: float) -> void:
	var parent = get_parent()
	if parent.has_method("get") and parent.get("waiting_for_key_release"):
		return

	if not animated_ship.is_playing():
		animated_ship.play("MatherV0.3")
	
	#FORWARD MOTION
	if Input.is_action_just_pressed("move_forward"):
		is_moving_forward = !is_moving_forward
	if is_moving_forward:
		current_speed = move_toward(current_speed, speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0, deceleration * delta)
	
	#TURNING
	Main.encoder_delta = lerp(Main.encoder_delta, 0.0, turn_deceleration * delta)
	#non linear=-86eqdoesn't jump
	var sensitivity_exponent = 0.8  
	var adjusted_input = sign(Main.encoder_delta) * pow(abs(Main.encoder_delta), sensitivity_exponent)
	
	#test
	var keyboard_input = Input.get_action_strength("rudder_right") - Input.get_action_strength("rudder_left")
	var combined_input = adjusted_input + keyboard_input
	var target_turn_velocity = combined_input * turn_speed
	#var target_turn_velocity = adjusted_input * turn_speed
	#end test

	current_turn_velocity = move_toward(current_turn_velocity, target_turn_velocity, turn_acceleration * delta)
	rotation += current_turn_velocity * delta
	
	if rotation != last_heading:
		emit_signal("heading_changed", rotation)
		last_heading = rotation
	
	#MOVEMENT
	var forward_vector = Vector2.RIGHT.rotated(rotation)
	velocity = forward_vector * current_speed
	move_and_slide()
	
	#COLLISION DETECTION
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
	
	#END SCREEN
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
		return false  #let the game run if i mess up the map lol
		
	var collision_shape = $CollisionPolygon2D
	#changed to make much much more simple
	for point in collision_shape.polygon:
		var world_point = to_global(point)
		var tile_pos = tilemap.local_to_map(world_point)
		var tile_data = tilemap.get_cell_tile_data(tile_pos)
		if tile_data and tile_data.get_custom_data("is_end_tile"):
			return true 
	return false
