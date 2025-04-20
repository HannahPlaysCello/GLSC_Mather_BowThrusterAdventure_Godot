extends Control

func _input(event):
	if (event is InputEventAction and event.pressed) or (event is InputEventKey and event.pressed): #get literally any input please i swear to god
		Main.change_scene("res://Scenes/Menu.tscn")
