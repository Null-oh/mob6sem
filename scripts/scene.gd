#это уровень
extends Node2D

@onready var despawner = $despawner
@onready var collider = $despawner/despawnerArea
@onready var screensize: Vector2 = get_viewport().get_visible_rect().size
@onready var path = $mw_path/mw_spawn

@export var mw_scene = preload("res://assets/materwelon.tscn")
enum Level { BIG, MID, SMALL, DED}

func _ready():
	#collider.collision_mask = 1
	for i in 3:
		spawn_materwelon(Level.BIG)
	
	print(Global)

#func _on_despawner_area_body_entered(body):
		#if body.is_in_group("socks"):
			#print("sock gone: ", body.name)
			#body.queue_free()
		#
		#if body.is_in_group("materwelons"): pass

func spawn_materwelon(level, mw_position = null, mw_velocity = null):
	if Global.materwelons >= 5:
		return
	
	if mw_position == null:
		path.progress = randi()
		mw_position = path.position
	if mw_velocity == null:
		mw_velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
	
	var mw_instance = mw_scene.instantiate()
	add_child(mw_instance)
	mw_instance.screensize = screensize
	mw_instance.start(mw_position, mw_velocity, level)
	Global.materwelons += 1
