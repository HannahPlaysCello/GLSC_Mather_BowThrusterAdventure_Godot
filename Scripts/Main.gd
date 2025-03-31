extends Node

#switch scenes
func change_scene(scene_path: String):
	GameState.handle_scene_change(scene_path)
	get_tree().change_scene_to_file(scene_path)

#timeout
var idle_timer = 0
const IDLE_TIME_LIMIT = 30.0  #change this for timeout timer

#serial stuff here 
func _ready():
	#connect to SerialReader.cs signals
	if has_node("/root/SerialReader"):
		var serial_reader = get_node("/root/SerialReader")
		serial_reader.connect("DataReceived", Callable(self, "_on_serial_data_received"))
		print("Connected to SerialReader signal!")
	else:
		print("Error: SerialReader not found")

func _on_serial_data_received(data):
	#print("Received from Arduino: ", data)
	handle_serial_command(data)

#handle serial data
func handle_serial_command(data: String):
	var event = InputEventAction.new()

	match data:
		"BTN_1_PRESSED":
			event.action = "move_forward"
			event.pressed = true
		"BTN_1_RELEASED":
			event.action = "move_forward"
			event.pressed = false
		"BTN_2_PRESSED":
			event.action = "thruster_left"
			event.pressed = true
		"BTN_2_RELEASED":
			event.action = "thruster_left"
			event.pressed = false
		"BTN_3_PRESSED":
			event.action = "thruster_right"
			event.pressed = true
		"BTN_3_RELEASED":
			event.action = "thruster_right"
			event.pressed = false
		"ROT_LEFT":
			event.action = "rudder_left"
			event.pressed = true
		"ROT_RIGHT":
			event.action = "rudder_right"
			event.pressed = true
		_:
			print("Unknown command:", data)
			return
	Input.parse_input_event(event)

func _process(delta):
	if Input.is_anything_pressed():
		idle_timer = 0  # reset timer
	else:
		idle_timer += delta

	if idle_timer >= IDLE_TIME_LIMIT:
		change_scene("res://Scenes/StartScreen.tscn")

	if Input.is_action_pressed("menu"):
		change_scene("res://Scenes/Menu.tscn")
