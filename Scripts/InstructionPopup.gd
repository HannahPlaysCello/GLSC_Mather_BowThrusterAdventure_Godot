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

func center_popup():
	var screen_size = get_viewport_rect().size
	var popup_size = $Panel.size  # Adjust based on actual Panel size
	$Panel.position = (screen_size - popup_size) / 2

func _input(event):
	if event.is_action_pressed("move_forward"):
		visible = false
		popup_dismissed.emit()
		set_process_input(false)
