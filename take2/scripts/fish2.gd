#это рыба
extends RigidBody2D

enum {INIT, ALIVE, SAFE, DED}
var state = INIT

@export var engine_power = 1000
@export var spin_power = 20000
var thrust = Vector2.ZERO
var rotation_dir = 0

@onready var screensize = get_viewport_rect().size

@onready var interface = $"../interface"
var is_thrust : bool = false
var is_left : bool = false
var is_right : bool = false
var is_fire : bool = false

@export var sock_scene : PackedScene
@export var fire_rate = 0.25
var can_shoot = true
@onready var cooldown = $sock_cooldown

signal fsh_ded
var lives : int

var reset_pos : bool = false

@onready var sprite = $Sprite2D
@onready var bubbles = $bubbles
@onready var salmon = $salmon

@export var max_shield : float = 100
@export var shield_regen : float = 5

@onready var shoot_sound = $shoot
@onready var short1 = preload("res://sounds/short1.mp3")
@onready var short2 = preload("res://sounds/short2.mp3")
@onready var short3 = preload("res://sounds/short3.mp3")
@onready var short4 = preload("res://sounds/short4.mp3")

@onready var thrust_sound = $thrust
@onready var long1 = preload("res://sounds/long1.mp3")
@onready var long2 = preload("res://sounds/long2.mp3")



func _ready():
	change_state(ALIVE)
	lives = Global2.lives
	reset_pos = true
	
	cooldown.wait_time = fire_rate
	
	bubbles.emitting = false
	salmon.emitting = false
	
	if interface:
		interface.thrust_signal.connect(_on_thrust_signal)
		interface.thrust_up.connect(_on_thrust_up)
		interface.left_signal.connect(_on_left_signal)
		interface.left_up.connect(_on_left_up)
		interface.right_signal.connect(_on_right_signal)
		interface.right_up.connect(_on_right_up)
		interface.fire_signal.connect(_on_fire_signal)
		interface.fire_up.connect(_on_fire_up)

func change_state(new_state):
	match new_state:
		INIT:
			sprite.modulate.a = 0.5
		ALIVE:
			sprite.modulate.a = 1.0
		SAFE:
			sprite.modulate.a = 0.5
		DED: 
			linear_velocity = Vector2.ZERO
			fsh_ded.emit()
	state = new_state

func _process(delta):
	get_input()
	Global2.shield += shield_regen * delta
	Global2.shield = min(Global2.shield, max_shield)
	if Global2.shield <= 0:
		Global2.lives -= 1
		Global2.shield = max_shield

func play_short():
	var sounds = [short1, short2, short3, short4 ]
	var random_index = randi() % sounds.size()
	shoot_sound.stream = sounds[random_index]
	shoot_sound.play()

func play_long():
	if thrust_sound.playing:
		return
	
	var sounds = [long1, long2 ]
	var random_index = randi() % sounds.size()
	thrust_sound.stream = sounds[random_index]
	thrust_sound.play()

func get_input():
	if !Global2.playing:
		return
	
	thrust = Vector2.ZERO
	if state in [DED, INIT]:
		return
	
	if Input.is_action_pressed("ui_up") or is_thrust:
		thrust = - transform.y * engine_power
		bubbles.emitting = true
		play_long()
	else:
		bubbles.emitting = false
		thrust_sound.stop()
	
	var input_dir = 0
	if is_left:
		input_dir -= 1
	if is_right:
		input_dir += 1
	
	input_dir += Input.get_axis("ui_left", "ui_right")
	rotation_dir = clamp(input_dir, -1, 1)
	
	if Input.is_action_pressed("space") or is_fire:
		shoot()

func _physics_process(_delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power

func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform
	
	if reset_pos:
		physics_state.transform.origin = screensize / 2
		reset_pos = false

func shoot():
	if state == SAFE:
		return
	if !can_shoot:
		return
	
	can_shoot = false
	cooldown.start()
	var sock_instance = sock_scene.instantiate()
	get_tree().root.add_child(sock_instance)
	sock_instance.start($muzzle.global_transform)
	play_short()

func _on_body_entered(body):
	if body.is_in_group("materwelons") or body.is_in_group("food"):
		salmon.emitting = true
		
		Global2.shield -= 25
		
		if Global2.shield <= 0:
			Global2.lives -= 1
			Global2.shield = max_shield
		
		if body.is_in_group("materwelons"):
			Global2.materwelons -= 1
		body.queue_free()

func _on_sock_cooldown_timeout():
	can_shoot = true

func _on_thrust_signal():
	is_thrust = true

func _on_thrust_up():
	is_thrust = false

func _on_left_signal():
	is_left = true

func _on_right_signal():
	is_right = true

func _on_left_up():
	is_left = false

func _on_right_up():
	is_right = false

func _on_fire_signal():
	is_fire = true

func _on_fire_up():
	is_fire = false
