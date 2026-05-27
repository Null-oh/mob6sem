#это ю эс э
extends Area2D

@onready var bullet_scene = preload("res://assets/food.tscn")

@export var draw_path : Path2D
@onready var paths = $enemy_paths

var follow = PathFollow2D.new()

var health : int = 3

@export var speed = 150
@export var rotation_speed = 120

@export var bullet_spread = 0.2

var target = null

@onready var aPlayer = $AnimationPlayer
@onready var cooldown_timer = $cooldown

func _ready():
	add_to_group("enemies")

	var path = paths.get_children()[randi_range(0, 2)]
	path.add_child(follow)
	follow.loop = false
	
	cooldown_timer.start()

func _physics_process(delta):
	follow.progress += speed * delta
	position = follow.global_position
	
	if target:
		var direction = global_position.direction_to(target.global_position)
		rotation = direction.angle() + PI
	
	if follow.progress_ratio >= 1:
		queue_free()
		Global2.is_enemy = false
	
	if health <= 0:
		Global2.score += 5
		queue_free()
		Global2.is_enemy = false

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
	
	await aPlayer.animation_finished
	if modulate != Color(1,1,1,1):
		modulate = Color(1,1,1,1)
	
	if health <= 0:
		explode()

func explode():
	speed = 0
	cooldown_timer.stop()

func _on_body_entered(body):
	if body.name == "Fish2":
		Global2.shield -= 50
		take_damage()
