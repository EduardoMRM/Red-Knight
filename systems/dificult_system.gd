extends Node

@export var mob_spwaner: MobSpawner
@export var spwan_rate_per_minutes: float = 30
@export var wave_duration: float = 25.0
@export var inital_spwan_rate: float = 120.0
@export var break_intensity: float = 0.5

var time:float = 0.0

func _process(delta: float) -> void:
	if GameManager.is_game_over: return
	
	time += delta
	
	var spaw_rate = inital_spwan_rate + spwan_rate_per_minutes * (time / 60)
	mob_spwaner.mobs_per_minute = spaw_rate
	
	var sin_wave = sin((TAU * time) / wave_duration) # 2PI = TAU
	var wave = remap(sin_wave, -1.0, 1.0, break_intensity, 1.0)
	
	spaw_rate *= wave
