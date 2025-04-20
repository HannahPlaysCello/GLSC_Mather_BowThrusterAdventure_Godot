extends Node2D

@export var normal_ship_scene: PackedScene
@export var thruster_ship_scene: PackedScene
@export var river_map_scene: PackedScene 
@export var harbor_map_scene: PackedScene 

var ship
var tilemap
@onready var spawn_ship = $SpawnShip 
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var instruction_popup: Control = preload("res://Scenes/InstructionPopup.tscn").instantiate()
var waiting_for_key_release = false

var practice_collisions = 0

func _ready():
	GameState.reset_collision_count()
	score_label.visible = true
	load_selected_map()
	spawn_selected_ship()
	add_child(instruction_popup)
	
	var instructions := "Use the wheel to steer the ship using the rudder. Press the green start button to start and stop the ship."
	if GameState.selected_ship == GameState.ShipType.THRUSTERS:
		instructions = "Use the wheel to steer the ship using the rudder & the triangular buttons to move sideways with the thrusters. Press the green start button to start and stop the ship."

	instruction_popup.show_popup(instructions)
	instruction_popup.popup_dismissed.connect(on_popup_dismissed) 

func on_popup_dismissed():
	waiting_for_key_release = true
	
func _input(event):
	if waiting_for_key_release and event.is_action_released("move_forward"):
		waiting_for_key_release = false

func load_selected_map():
	#no maps!
	if tilemap:
		tilemap.queue_free()
	
	if GameState.selected_map == GameState.MapType.RIVER:
		tilemap = river_map_scene.instantiate()
	else:
		tilemap = harbor_map_scene.instantiate()
	
	add_child(tilemap)


func spawn_selected_ship():
	#load ship
	if GameState.selected_ship == GameState.ShipType.NORMAL:
		ship = normal_ship_scene.instantiate()
	else:
		ship = thruster_ship_scene.instantiate()
	add_child(ship)
	ship.tilemap = tilemap #pass to ship
	ship.position = spawn_ship.position
	ship.collision_happened.connect(_on_collision_detected)
	
func _on_collision_detected():
	practice_collisions += 1
	score_label.text = "Collisions: " + str(practice_collisions)
	
func end_game():
	GameState.practice_score = practice_collisions
	Main.change_scene("res://Scenes/PracticeEndScreen.tscn")
