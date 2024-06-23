extends Node

signal game_ended

var player: Player
var player_position: Vector2
var is_game_over: bool = false
var time_elapsed: float = 0.0
var time_elapsed_string: String
var meat_counter: int = 0
var time_survived: String
var monsters_defeated: int
var monsters_defeated_counter: int = 0

func _process(delta: float):
	#Uptade timer
	time_elapsed += delta
	var time_elapsed_in_seconds: int = floori(time_elapsed)
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int = time_elapsed_in_seconds / 60
	
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]

func end_game():
	if is_game_over: return
	is_game_over = true
	game_ended.emit()
