extends Control

@onready var buttons = $HBoxContainer.get_children()
var selected_index = 0

func _ready():
	for b in buttons:
		b.focus_mode = Control.FOCUS_CLICK
	update_selection()

func _input(event):
	if event.is_action_pressed("thruster_left") or event.is_action_pressed("rudder_left"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		update_selection()

	elif event.is_action_pressed("thruster_right") or event.is_action_pressed("rudder_right"):
		selected_index = (selected_index + 1) % buttons.size()
		update_selection()

	elif event.is_action_pressed("move_forward"):  #space or enter
		handle_selection()

	if event is InputEventAction:
		print(event.action, event.pressed)

func update_selection():
	buttons[selected_index].grab_focus()
	#for i in range(buttons.size()):
		#buttons[selected_index].grab_focus()
		#buttons[i].modulate = Color(1, 1, 1, 1)
	
	#buttons[selected_index].modulate = Color(1, 1, 0, 1)  #rgba = yellow
	

func handle_selection():
	match selected_index:
		0: Main.change_scene("res://Scenes/PracticeSetup.tscn")
		1: Main.change_scene("res://Scenes/ChallengeMode.tscn")
		2: Main.change_scene("res://Scenes/LearnMore.tscn")
		#3: Main.change_scene("res://Scenes/Credits.tscn")
