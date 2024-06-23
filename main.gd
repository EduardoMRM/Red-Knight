extends Node2D

@export var game_UI: CanvasLayer
@export var game_over_UI: PackedScene

func _ready():
	GameManager.game_ended.connect(trigger_game_over)

func trigger_game_over():
	# Deletar game_UI
	if game_UI:
		game_UI.queue_free()
		game_UI = null
	
	# Criar game_over_UI
	var game_over: GameOverUI = game_over_UI.instantiate()
	add_child(game_over)
