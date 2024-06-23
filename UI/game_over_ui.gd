class_name GameOverUI
extends CanvasLayer

@onready var timeLabel: Label = %TimeLabel
@onready var monstersLabel: Label = %MonstersLabel

func _ready():
	timeLabel.text = GameManager.time_elapsed_string
	monstersLabel.text = str(GameManager.monsters_defeated_counter)

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
	GameManager.is_game_over = false
	
	GameManager.time_elapsed = 0.0
	GameManager.time_elapsed_string = ""
	GameManager.meat_counter = 0
	GameManager.monsters_defeated_counter = 0
