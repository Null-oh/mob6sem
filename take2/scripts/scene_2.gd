extends Node2D

@export var materwelon_scene : PackedScene
@onready var screensize : Vector2 = get_viewport().get_visible_rect().size

@onready var spawn_path = $mwpath/mwspawn

func _ready():
	for i in 3:
		spawn()

func spawn(mwposition = null, mwvelocity = null):
	if mwposition == null:
		spawn_path.progress = randi()
		mwposition = spawn_path.position
	
	if mwvelocity == null:
		mwvelocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
	
	var mw_instance = materwelon_scene.instantiate()
	mw_instance.screensize = screensize
	mw_instance.start(mwposition, mwvelocity)
	call_deferred("add_child", mw_instance)
