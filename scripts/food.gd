#это еда
extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var sprites = $sprites

var speed = 600
var rotation_speed = 10.0 
var velocity = Vector2.ZERO
var angular_velocity = 0.0

func _ready():
	add_to_group("food")
	
	sprite.frame = randi_range(0, 2)
	angular_velocity = randf_range(-rotation_speed, rotation_speed)
	
	body_entered.connect(_on_body_entered)

func start(_position, _direction):
	position = _position
	rotation = _direction.angle()
	velocity = _direction * speed

func _process(delta):
	position += velocity * delta
	rotation += angular_velocity * delta

func _on_body_entered(body):
	if body.name == "Fish2":
		print("fsh hit")
	
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
