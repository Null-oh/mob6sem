extends Area2D

@export var draw_path : Path2D
@onready var paths = $enemy_paths

var follow = PathFollow2D.new()

var health : int = 3

@export var speed = 150
@export var rotation_speed = 120

@export var bullet_spread = 0.2

var target = null

@onready var bullet_scene = preload("res://assets/food.tscn")

@onready var aPlayer = $AnimationPlayer

func _ready():
	add_to_group("enemies")
	var path = paths.get_children()[randi_range(0, 2)]
	path.add_child(follow)
	follow.loop = false

func _physics_process(delta):
	rotation += deg_to_rad(rotation_speed) * delta
	
	follow.progress += speed * delta
	position = follow.global_position
	
	if follow.progress_ratio >= 1:
		queue_free()
	
	if health <= 0:
		Global2.score += 5
		queue_free()

func shoot():
	var dir = global_position.direction_to(target.global_position)
	dir = dir.rotated(randf_range(-bullet_spread, bullet_spread))
	
	var bullet_instance = bullet_scene.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.start(global_position, dir)

func pulse(n, delay):
	for i in n:
		shoot()
		await get_tree().create_timer(delay).timeout

func _on_cooldown_timeout():
	pulse(3, 0.15)

func take_damage():
	health -= 1
	aPlayer.play("flash")
	if health <= 0:
		explode()

func explode():
	speed = 0
	$cooldown.stop()
	
