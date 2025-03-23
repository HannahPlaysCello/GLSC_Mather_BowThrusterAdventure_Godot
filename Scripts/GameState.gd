extends Node

#for music
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
const MUSIC_FILE_PATH = "res://Assets/Riverboat_Shuffle_-_Bix_Beiderbecke_and_Wolverine_Orchestra_1924.ogg"

#track current game mode
enum GameMode { MENU, PRACTICE, CHALLENGE }
var current_mode = GameMode.MENU

#track ships and maps
enum ShipType { NORMAL, THRUSTERS }
var selected_ship = ShipType.NORMAL

enum MapType { RIVER, PORT }
var selected_map = MapType.RIVER

#track challenge phase
var challenge_phase_one = true
var collisions_no_thrusters = 0
var collisions_with_thrusters = 0

#transition scenes
func change_scene(target_scene: String):
	get_tree().change_scene_to_file(target_scene)


######################## music ##################
var excluded_scenes = [
	"res://Scenes/Menu.tscn",
	"res://Scenes/StartScreen.tscn",
	"res://Scenes/Credits.tscn",
	"res://Scenes/PracticeSetup.tscn"
]

func _ready():
	add_child(music_player)
	music_player.stream = load(MUSIC_FILE_PATH)
	music_player.bus = "Music"
	if music_player.stream is AudioStream:
		music_player.stream.set_loop(true)
	
func play_music():
	if not music_player.playing:
		music_player.play()

func stop_music():
	if music_player.playing:
		music_player.stop()

func handle_scene_change(target_scene: String):
	if target_scene in excluded_scenes:
		stop_music()
	else:
		play_music()




######################## SCORE TRACKING #######################
var is_colliding = false 
var collision_count = 0
var practice_score = 0

func reset_collision_count():
	collision_count = 0
	is_colliding = false

func reset_challenge_scores():
	collisions_no_thrusters = 0
	collisions_with_thrusters = 0
	reset_collision_count()

var high_scores = []

const SCORE_FILE_PATH = "user://high_scores.json" #wonder if i should change this? does it generate the file? help! 

#add score to file
func add_score(new_score):
	high_scores.append(new_score)
	high_scores.sort()
	high_scores.reverse()
	if high_scores.size() > 10:  #keeps this number of scores, change in next line too!
		high_scores = high_scores.slice(0, 10)
	save_scores()

func save_scores():
	var file = FileAccess.open(SCORE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(high_scores))
		file.close()
	else:
		print("Error: Unable to open file for saving scores")

#load scores from file
func load_scores():
	if FileAccess.file_exists(SCORE_FILE_PATH):
		var file = FileAccess.open(SCORE_FILE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			high_scores = JSON.parse_string(content) if content else []
			file.close()
