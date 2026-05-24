#это рыба
extends RigidBody2D

enum {INIT, ALIVE, SAFE, DED}
var state = INIT

@export var engine_power = 1000
@export var spin_power = 50000
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

signal lives_changed
signal fsh_ded
var lives : int

var reset_pos : bool = false

@onready var sprite = $Sprite2D

func _ready():
	change_state(ALIVE)
	lives = Global2.lives
	reset_pos = true
	
	cooldown.wait_time = fire_rate
	
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

func _process(_delta):
	get_input()

func get_input():
	thrust = Vector2.ZERO
	if state in [DED, INIT]:
		return
	
	if Input.is_action_pressed("ui_up") or is_thrust:
		thrust = - transform.y * engine_power
	
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


func _on_body_entered(body):
	if body.is_in_group("materwelons"):
		print("collision")
		Global2.lives -= 1
