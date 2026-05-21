#это корабль
extends CharacterBody2D

@onready var sprite = $Sprite2D

@onready var screensize = get_viewport_rect().size

var target_position: Vector2
var is_moving: bool = false
var is_dragging: bool = false

var direction
var distance

@export var rotation_speed: float = 10.0
@export var speed: float = 500

@export var health : int = 10

func _ready():
	position = Vector2.ZERO
	collision_layer = 1
	collision_mask = 0 
	print("fish ready")

func _physics_process(delta):
	if not is_dragging and not is_moving:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	direction = global_position.direction_to(target_position)
	distance = global_position.distance_to(target_position)
		
	if distance > 5.0:
		if sprite:
			var target_rotation = direction.angle()
			sprite.rotation = lerp_angle(sprite.rotation, target_rotation, rotation_speed*delta)
			
		velocity = direction * speed
		move_and_slide()
		
	else:
		velocity = Vector2.ZERO
		is_moving = false
		move_and_slide()
	
	if health <= 0:
		self.queue_free()

func _input(event):
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
	or (event is InputEventScreenTouch and event.pressed):
		is_dragging = true
		is_moving = true
		target_position = get_global_mouse_position()
	
	if (event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
	or (event is InputEventScreenTouch and not event.pressed):
		is_dragging = false
	
	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and is_dragging:
		target_position = get_global_mouse_position()
		is_moving = true
	
	if Input.is_action_just_pressed("space"):
		fire()


func fire():
	var sock = preload("res://assets/sock.tscn")
	var instance = sock.instantiate()
	get_tree().current_scene.add_child(instance)
	
	var shoot_dir = Vector2.RIGHT.rotated(sprite.rotation)
	var spawn_offset = shoot_dir * 40
	
	instance.global_position = global_position + spawn_offset
	
	instance.velocity = shoot_dir * instance.speed
