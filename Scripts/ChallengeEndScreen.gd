extends Control

@onready var title_label = $Label
@onready var score_label = $ScoreLabel
@onready var buttons = $options.get_children()
var selected_index = 0

func _ready():
	update_selection()
	title_label.text = "Great job! You navigated like a pro!"
	score_label.text = "No Thrusters: " + str(GameState.collisions_no_thrusters) + "\nWith Thrusters: " + str(GameState.collisions_with_thrusters)

func _input(event):
	if event.is_action_pressed("thruster_left"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		update_selection()

	elif event.is_action_pressed("thruster_right"):
		selected_index = (selected_index + 1) % buttons.size()
		update_selection()

	elif event.is_action_pressed("move_forward"):
		handle_selection()

func _on_play_again_pressed():
	Main.change_scene("res://Scenes/ChallengeMode.tscn")

func _on_return_to_menu_pressed():
	Main.change_scene("res://Scenes/Menu.tscn")
	
func update_selection():
	buttons[selected_index].grab_focus()

func handle_selection():
	match selected_index:
		0: Main.change_scene("res://Scenes/LearnMore.tscn")
		1: Main.change_scene("res://Scenes/Menu.tscn")
