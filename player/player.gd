class_name Player 
extends CharacterBody2D

@export var speed: float = 3
@export var sword_damage: int = 5
@export var ritual_damage: int = 5
@export var ritual_interval: float = 15
@export var ritual_scene: PackedScene
@export var health: int = 10
@export var max_health: int = 15
@export var death_prefab: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitBoxArea
@onready var healt_progress_bar: ProgressBar = $HealthProgressBar

var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var cooldown_attack: float = 0.0
var cooldown_hitbox: float = 0.0
var ritual_cooldow: float = 0.0

signal meat_collected(value: int)

func _ready():
	GameManager.player = self
	meat_collected.connect(
		func(value: int): GameManager.meat_counter += 1)

func _process(delta: float) -> void:
	GameManager.player_position = position
	
	read_input()
	play_animation()
	update_attack_cooldown(delta)
	take_damage(delta)
	uptade_ritual(delta)
	
	healt_progress_bar.max_value = max_health
	healt_progress_bar.value = health

func _physics_process(delta: float) -> void:
	# Modificar velocidade
	var target_velocity = input_vector * speed * 150.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()

func update_attack_cooldown(delta: float) -> void:
	# Atualizar tempo do ataque
	if is_attacking:
		cooldown_attack -= delta
		if cooldown_attack <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func play_animation() -> void:
	# Tocar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")
		
	# Girar sprite
	if not is_attacking: 
		if input_vector.x > 0:
			sprite.flip_h = false
		elif input_vector.x < 0:
			sprite.flip_h = true
	
	# Ataque
	if Input.is_action_just_pressed("attack"):
		attack()

func read_input() -> void:
	# Obter o input_vecto
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Apagar o deadzone
	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
	
	# Atualizar o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func attack() -> void:
	if is_attacking:
		return
	animation_player.play("attack_side_1")
	cooldown_attack = 0.6
	
	is_attacking = true

func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.4:
				enemy.damage(sword_damage)

func damage(amount: int) -> void:
	if health <= 0: return
	
	health -= amount
	
	# Piscar inimigo
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Processar morte
	if health <= 0:
		die()

func take_damage(delta: float) -> void:
	# Temporizador
	cooldown_hitbox -= delta
	if cooldown_hitbox >= 0 : return
	
	# Frequência
	cooldown_hitbox = 0.5
	
	# Detectar Inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)

func die() -> void:
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	queue_free()

func heal(amount: int) -> int:
	health += amount
	if health >= max_health:
		health = max_health
	modulate = Color.GREEN
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	return health

func uptade_ritual(delta: float) -> void:
	# Atualizar temporizador
	ritual_cooldow -= delta
	if ritual_cooldow > 0: return
	ritual_cooldow = ritual_interval
	
	# Criar ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
