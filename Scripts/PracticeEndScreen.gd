extends Control

@onready var score = $Score
@onready var buttons = $endScreenOptions.get_children()
var selected_index = 0
var final_score = 0

func _ready():
	update_selection()
	score.text = "Collisions: " + str(GameState.practice_score)

func _input(event):
	if event.is_action_pressed("thruster_left"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		update_selection()

	elif event.is_action_pressed("thruster_right"):
		selected_index = (selected_index + 1) % buttons.size()
		update_selection()

	elif event.is_action_pressed("move_forward"):
		handle_selection()

func update_selection():
	buttons[selected_index].grab_focus()
	#for i in range(buttons.size()):
	#	buttons[i].modulate = Color(1, 1, 1, 1)
	
	#buttons[selected_index].modulate = Color(1, 1, 0, 1)  #rgba = yellow

#func update_selection():
	#buttons[selected_index].grab_focus()
	#for i in range(buttons.size()):
		#buttons[selected_index].grab_focus()
		#buttons[i].modulate = Color(1, 1, 1, 1)
	
	#buttons[selected_index].modulate = Color(1, 1, 0, 1)  #rgba = yellow

func handle_selection():
	match selected_index:
		0: Main.change_scene("res://Scenes/ChallengeMode.tscn")
		1: Main.change_scene("res://Scenes/Menu.tscn")
