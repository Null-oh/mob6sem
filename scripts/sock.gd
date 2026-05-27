#это носок
extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var muzzle = $muzzle

var speed = 800
var rotation_speed = 10.0 
var velocity = Vector2.ZERO

@onready var colours = ["yellow", "red", "green", "orange"]

func _ready():
	add_to_group("socks")
	collision_layer = 2
	collision_mask = 1
	var chosen_colour = colours.pick_random()
	sprite.play(chosen_colour)
	
	body_entered.connect(_on_body_entered)
	
	collision_layer = 1


func start(_transform):
	transform = _transform
	velocity = - transform.y * speed

func _process(delta):
	position += velocity * delta
	rotation += rotation_speed * delta

func _on_body_entered(body):
	if body.is_in_group("materwelons"):
		body.hit()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.take_damage()
		queue_free()
	
	if area.is_in_group("food"):
		area.queue_free()
