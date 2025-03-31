extends Control

func _input(event):
	if event is InputEventAction and event.pressed: #get literally any input
		Main.change_scene("res://Scenes/Menu.tscn")
