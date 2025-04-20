extends Control

func change_scene(scene_path: String):
	GameState.handle_scene_change(scene_path)
	get_tree().change_scene_to_file(scene_path)

func _input(event):
	if event.is_action_pressed("move_forward"):
		change_scene("res://Scenes/Menu.tscn")
