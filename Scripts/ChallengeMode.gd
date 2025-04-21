extends Node2D

enum Phase {
	NAVIGATE_NO_THRUST,
	HARBOR_NO_THRUST,
	TRANSITION,
	NAVIGATE_WITH_THRUST,
	HARBOR_WITH_THRUST
}

@export var normal_ship_scene: PackedScene
@export var thruster_ship_scene: PackedScene
@export var river_map_scene: PackedScene
@export var harbor_map_scene: PackedScene

var current_phase: Phase = Phase.NAVIGATE_NO_THRUST
var ship: Node
var tilemap: Node

var can_advance: bool = true
var waiting_for_key_release: bool = false

@onready var spawn_point: Node2D = $ShipSpawn
@onready var phase_label: Label = $Labels/PhaseLabel
@onready var tilemap_container: Node = $TileMapContainer
@onready var overlay: Control = $Labels/Overlay
@onready var score_label: Label = $Labels/ScoreLabel
@onready var instruction_popup: Control = preload("res://Scenes/InstructionPopup.tscn").instantiate()

func _ready() -> void:
	add_child(instruction_popup)
	GameState.reset_collision_count()
	overlay.visible = false
	start_phase(Phase.NAVIGATE_NO_THRUST)
	show_instruction("Use the wheel to steer the ship using the rudder. Press the green start button to start and stop the ship.", _on_first_instruction_dismissed)

func show_instruction(message: String, callback: Callable) -> void:
	instruction_popup.show_popup(message)
	instruction_popup.popup_dismissed.connect(callback)

func _on_first_instruction_dismissed() -> void:
	waiting_for_key_release = true

func _input(event: InputEvent) -> void:
	if waiting_for_key_release:
		if event.is_action_released("move_forward"):
			waiting_for_key_release = false
		return

	if event.is_action_released("move_forward"):
		match current_phase:
			Phase.TRANSITION:
				overlay.visible = false
				start_phase(Phase.NAVIGATE_WITH_THRUST)
				show_instruction("You now have bow thrusters! Use the triangular buttons to move sideways with the thrusters.", _on_second_instruction_dismissed)
			_:
				pass

func _on_second_instruction_dismissed() -> void:
	waiting_for_key_release = true

func start_phase(phase: Phase) -> void:
	current_phase = phase
	match phase:
		Phase.NAVIGATE_NO_THRUST:
			phase_label.text = "Can you navigate Collision Bend without thrusters?"
			load_map(river_map_scene)
			spawn_ship_instance(normal_ship_scene)
		Phase.HARBOR_NO_THRUST:
			phase_label.text = "Welcome to Cleveland! Can you navigate the Mather into port without thrusters?"
			load_map(harbor_map_scene)
			spawn_ship_instance(normal_ship_scene)
		Phase.TRANSITION:
			overlay.visible = true
			overlay.get_node("Label").text = "In 1964, state-of-the-art bow thrusters were installed in the Mather!\nPress the green button to continue."
		Phase.NAVIGATE_WITH_THRUST:
			phase_label.text = "Try navigating Collision Bend with bow thrusters"
			load_map(river_map_scene)
			spawn_ship_instance(thruster_ship_scene)
			can_advance = false
			await get_tree().create_timer(1.0).timeout
			can_advance = true
		Phase.HARBOR_WITH_THRUST:
			phase_label.text = "Welcome to Cleveland! Can you navigate the Mather into port using your thrusters?"
			load_map(harbor_map_scene)
			spawn_ship_instance(thruster_ship_scene)

func load_map(map_scene: PackedScene) -> void:
	if tilemap:
		tilemap.queue_free()
	tilemap = map_scene.instantiate()
	tilemap_container.add_child(tilemap)

func spawn_ship_instance(ship_scene: PackedScene) -> void:
	if ship:
		ship.queue_free()
	ship = ship_scene.instantiate()
	ship.tilemap = tilemap
	ship.position = spawn_point.position
	add_child(ship)
	if ship.get_slide_collision_count() > 0:
		ship.position.y -= 10
	ship.process_mode = Node.PROCESS_MODE_INHERIT

func advance_challenge_phase() -> void:
	if not can_advance:
		return
	match current_phase:
		Phase.NAVIGATE_NO_THRUST:
			start_phase(Phase.HARBOR_NO_THRUST)
		Phase.HARBOR_NO_THRUST:
			GameState.collisions_no_thrusters = GameState.collision_count
			GameState.reset_collision_count()
			start_phase(Phase.TRANSITION)
		Phase.NAVIGATE_WITH_THRUST:
			start_phase(Phase.HARBOR_WITH_THRUST)
		Phase.HARBOR_WITH_THRUST:
			GameState.collisions_with_thrusters = GameState.collision_count
			GameState.reset_collision_count()
			Main.change_scene("res://Scenes/ChallengeEndScreen.tscn")
		_:
			pass

func _process(_delta: float) -> void:
	score_label.text = "Collisions: " + str(GameState.collision_count)
