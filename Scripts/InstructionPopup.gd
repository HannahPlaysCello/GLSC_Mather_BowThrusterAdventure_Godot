extends Control

signal popup_dismissed  #sends when popup closes
@onready var instruction_label: Label = $Panel/Label

func _ready():
	visible = false  #hide it
	set_process_input(false)

func show_popup(text: String):
	instruction_label.text = text
	visible = true
	set_process_input(true)
	center_popup()

func center_popup(offset_y := -150):
	var screen_size = get_viewport_rect().size
	var popup_size = $Panel.size
	
	var x = (screen_size.x - popup_size.x) / 2
	var y = (screen_size.y - popup_size.y) / 2 + offset_y
	$Panel.position = Vector2(x, y)

func _input(event):
	if event.is_action_pressed("move_forward"):
		visible = false
		popup_dismissed.emit()
		set_process_input(false)
