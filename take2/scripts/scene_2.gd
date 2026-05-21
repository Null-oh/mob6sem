#это уровень
extends Node2D

@export var materwelon_scene : PackedScene
@onready var screensize : Vector2 = get_viewport().get_visible_rect().size

@onready var spawn_path = $mwpath/mwspawn

func _ready():
	Global2.lives = 3

func _process(delta):
	if Global2.materwelons <= 0:
		spawn()

func spawn(mwposition = null, mwvelocity = null):
	for i in 3:
	
		if mwposition == null:
			spawn_path.progress = randi()
			mwposition = spawn_path.position
		
		if mwvelocity == null:
			mwvelocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
		
		var mw_instance = materwelon_scene.instantiate()
		mw_instance.screensize = screensize
		mw_instance.start(mwposition, mwvelocity)
		call_deferred("add_child", mw_instance)
