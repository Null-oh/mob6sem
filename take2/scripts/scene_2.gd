#это уровень
extends Node2D

@export var materwelon_scene : PackedScene
@onready var screensize : Vector2 = get_viewport().get_visible_rect().size

@onready var spawn_path = $mwpath/mwspawn
var spawning : bool = false

@onready var enemy_scene = preload("res://assets/enemy.tscn")
@onready var enemyTimer = $enemyTimer

func _ready():
	Global2.lives = 3
	Global2.score = 0
	Global2.materwelons = 0
	spawning = false
	
	enemyTimer.start(randf_range(5, 10))
	
	Global2.global_screensize = get_viewport().get_visible_rect().size

func _process(_delta):
	if !spawning and Global2.materwelons <= 0:
		spawn()
		spawning = true

func spawn():
	spawning = true
	for i in 3:
		var path_length = spawn_path.get_parent().curve.get_baked_length()
		spawn_path.progress = randf_range(0, path_length)
		var spawn_global_pos = spawn_path.global_position
		
		var velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
		
		var mw_instance = materwelon_scene.instantiate()
		mw_instance.screensize = screensize
		
		call_deferred("add_child", mw_instance)
		mw_instance.global_position = spawn_global_pos
		mw_instance.start(spawn_global_pos, velocity)
		
	await get_tree().create_timer(0.1).timeout
	print("spawn() завершён, spawning = false")
	spawning = false


func _on_enemy_timer_timeout():
	var enemy_instance = enemy_scene.instantiate()
	add_child(enemy_instance)
	enemy_instance.target = $Fish2
	enemyTimer.start(randf_range(20, 40))
