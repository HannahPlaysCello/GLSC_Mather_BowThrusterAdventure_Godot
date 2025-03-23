extends Control

@onready var score_container = $VBoxContainer

func _ready():
	GameState.load_scores()  # Load saved high scores

	# Clear existing labels
	for child in score_container.get_children():
		child.queue_free()

	# Display high scores
	for i in range(GameState.high_scores.size()):
		var label = Label.new()
		label.text = str(i + 1) + ". " + str(GameState.high_scores[i]) + " Collisions"
		score_container.add_child(label)

func _on_return_button_pressed():
	Main.change_scene("res://Scenes/Menu.tscn")
