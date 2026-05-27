#это арбуз
extends RigidBody2D

@onready var sprite = $sprite
@onready var collision_big = $collision_big
@onready var collision_mid = $collision_mid
@onready var collision_small = $collision_small

@onready var notifier = $notifier

#@onready var screensize = get_viewport_rect().size
var screensize: Vector2
@export var mw_scene = preload("res://assets/materwelon.tscn")

@onready var explosion_scene = preload("res://assets/mw_explosion.tscn")

var is_hiting = false

enum Level { BIG, MID, SMALL, DED}
var _level: Level
var level: Level:
	set(value):
		_level = value
		match _level:
			Level.BIG:
				sprite.play("big")
				collision_big.visible = true
				collision_mid.visible = false
				collision_small.visible = false
			Level.MID: 
				sprite.play("mid")
				collision_big.visible = false
				collision_mid.visible = true
				collision_small.visible = false
			Level.SMALL:
				sprite.play("small")
				collision_big.visible = false
				collision_mid.visible = false
				collision_small.visible = true
			Level.DED:
				Global2.materwelons -= 1
				self.queue_free()
	get:
		return _level

func _ready():
	add_to_group("materwelons")
	
	level = Level.BIG
	
	gravity_scale = 0
	linear_damp = 0
	angular_damp = 0

func start(_position, _velocity):
	position = _position
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)
	
	Global2.materwelons += 1
	
	screensize = Global2.global_screensize

func hit():
	if is_hiting:
		return
	
	is_hiting = true
	linear_velocity = Vector2(-abs(linear_velocity.x), linear_velocity.y)
	match level:
		Level.BIG:
			
			spawn_extra(Level.MID)
			level = Level.MID
			explode()
		Level.MID:
			
			spawn_extra(Level.SMALL)
			level = Level.SMALL
			explode()
		Level.SMALL:
			
			level = Level.DED
			Global2.score += 1
			explode()
		Level.DED: pass
	is_hiting = false

func explode():
	if explosion_scene:
		var explosion_instance = explosion_scene.instantiate()
		
		explosion_instance.position = global_position
		get_tree().root.add_child(explosion_instance)
		
		
		if explosion_instance is CPUParticles2D or explosion_instance is GPUParticles2D:
			explosion_instance.emitting = true

func _on_area_2d_body_entered(body):
	if body.is_in_group("socks"):
		hit()
		body.queue_free()

func teleport():
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	var camera_global_pos = camera.global_position
	var top_left = camera_global_pos - screensize * 0.5 / camera.zoom
	var bottom_right = camera_global_pos + screensize * 0.5 / camera.zoom
	
	var new_x = global_position.x
	var new_y = global_position.y
	
	if global_position.x < top_left.x:
		new_x = bottom_right.x - (top_left.x - global_position.x)
	elif global_position.x > bottom_right.x:
		new_x = top_left.x + (global_position.x - bottom_right.x)
	if global_position.y < top_left.y:
		new_y = bottom_right.y - (top_left.y - global_position.y)
	elif global_position.y > bottom_right.y:
		new_y = top_left.y + (global_position.y - bottom_right.y)
	
	global_position = Vector2(new_x, new_y)

func _on_notifier_screen_exited():
	teleport()

#func _integrate_forces(physics_state):
	#var xform = physics_state.transform
	#xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	#xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	#physics_state.transform = xform

func spawn_extra(new_level):
	var new_mw = mw_scene.instantiate()
	new_mw.screensize = Global2.global_screensize
	
	new_mw.position = position
	
	new_mw.linear_velocity = Vector2(abs(linear_velocity.x), linear_velocity.y) 
	new_mw.angular_velocity = angular_velocity
	
	get_parent().add_child(new_mw)
	new_mw.level = new_level
	Global2.materwelons += 1

func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform
