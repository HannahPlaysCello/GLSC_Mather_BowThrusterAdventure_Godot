extends Node

#switch scenes
func change_scene(scene_path: String):
	GameState.handle_scene_change(scene_path)
	get_tree().change_scene_to_file(scene_path)

#timeout
var idle_timer = 0
const IDLE_TIME_LIMIT = 30.0  #change this for timeout timer

func _process(delta):
	if Input.is_anything_pressed():
		idle_timer = 0  # reset timer
	else:
		idle_timer += delta

	if idle_timer >= IDLE_TIME_LIMIT:
		change_scene("res://Scenes/StartScreen.tscn")

	if Input.is_action_pressed("menu"):
		change_scene("res://Scenes/Menu.tscn")
