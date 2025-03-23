extends Control

func _input(event):
	if event is InputEventKey:  #for any key
		Main.change_scene("res://Scenes/Menu.tscn")
