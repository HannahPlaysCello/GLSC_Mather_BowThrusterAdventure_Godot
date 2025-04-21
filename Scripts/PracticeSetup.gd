extends Control

enum Step { SHIP_SELECTION, MAP_SELECTION }  
var current_step = Step.SHIP_SELECTION  

#ship and map choices
enum ShipType { NORMAL, THRUSTERS }
enum MapType { RIVER, PORT }

var selected_ship = ShipType.NORMAL
var selected_map = MapType.RIVER

@onready var label = $Label

#ship selection buttons
@onready var ship_normal_button = $ShipContainer/ShipNormal
@onready var ship_thrusters_button = $ShipContainer/ShipThrusters
@onready var ship_buttons = [ship_normal_button, ship_thrusters_button]

#map selection buttons
@onready var map_river_button = $MapContainer/MapRiver
@onready var map_port_button = $MapContainer/MapPort
@onready var map_buttons = [map_river_button, map_port_button]

#start with ship buttons
var options = ship_buttons

func _ready():
	update_selection()

func _input(event):
	if event.is_action_pressed("thruster_left"):
		if current_step == Step.SHIP_SELECTION:
			selected_ship = ShipType.NORMAL
		elif current_step == Step.MAP_SELECTION:
			selected_map = MapType.RIVER
		update_selection()

	elif event.is_action_pressed("thruster_right"):
		if current_step == Step.SHIP_SELECTION:
			selected_ship = ShipType.THRUSTERS
		elif current_step == Step.MAP_SELECTION:
			selected_map = MapType.PORT
		update_selection()

	elif event.is_action_pressed("move_forward"):
		if current_step == Step.SHIP_SELECTION:
			current_step = Step.MAP_SELECTION
			label.text = "Select Your Map"
			update_selection()
		else:
			start_practice_game()

func update_selection():
	if current_step == Step.SHIP_SELECTION:
		options = ship_buttons
	elif current_step == Step.MAP_SELECTION:
		options = map_buttons
	
	if current_step == Step.SHIP_SELECTION:
		options[selected_ship].grab_focus();  #highlight selected ship
	elif current_step == Step.MAP_SELECTION:
		options[selected_map].grab_focus();  #highlight selected map

func start_practice_game():
	GameState.selected_ship = selected_ship
	GameState.selected_map = selected_map
	Main.change_scene("res://Scenes/PracticeMode.tscn")
