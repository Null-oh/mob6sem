#это еда
extends Area2D

@onready var sprite = $Sprite2D
@onready var sprites = $sprites

var speed = 1000
var rotation_speed = 10.0 
var velocity = Vector2.ZERO

func _ready():
	add_to_group("food")
	var current_sprite = sprites.get_children()[randi_range(0, 2)]
	sprite.texture = current_sprite
	
	body_entered.connect(_on_body_entered)

func start(_position, _direction):
	position = _position
	rotation = _direction.angle()

func _process(delta):
	position += velocity * delta
	rotation += rotation_speed * delta


func _on_body_entered(body):
	if body.name == "Fish2":
		print("fsh hit")
	
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_cooldown_timeout():
	pass # Replace with function body.
