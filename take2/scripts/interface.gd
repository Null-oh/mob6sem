#это интерфейс
extends CanvasLayer

signal thrust_signal
signal thrust_up

signal left_signal
signal left_up

signal right_signal
signal right_up

signal fire_signal
signal fire_up

@onready var pause_window = $MarginContainer/pause
@onready var fail_window = $MarginContainer/fail

@onready var l1 = $MarginContainer/VBoxContainer/HBoxContainer4/lives/l1
@onready var l2 = $MarginContainer/VBoxContainer/HBoxContainer4/lives/l2
@onready var l3 = $MarginContainer/VBoxContainer/HBoxContainer4/lives/l3

@onready var score_label = $MarginContainer/VBoxContainer/HBoxContainer4/score

@onready var shield_texture = $MarginContainer/VBoxContainer/shield/TextureRect
@onready var shield_bar = $MarginContainer/VBoxContainer/shield/ProgressBar

func _ready():
	Engine.time_scale = 1
	Global2.lives = 3
	Global2.materwelons = 0
	pause_window.visible = false
	fail_window.visible = false
	score_label.text = str(Global2.score)
	set_lives()

func _process(_delta):
	set_lives()
	score_label.text = str(Global2.score)
	
	if Input.is_action_pressed("ui_cancel"):
		if pause_window.visible == false:
			_on_pause_pressed()
		else:
			_on_back_pressed()
	
	shield_bar.value = Global2.shield

func set_lives():
	match Global2.lives:
		3:
			l1.visible = true
			l2.visible = true
			l3.visible = true
		2: 
			l1.visible = true
			l2.visible = true
			l3.visible = false
		1:
			l1.visible = true
			l2.visible = false
			l3.visible = false
		0: 
			l1.visible = false
			l2.visible = false
			l3.visible = false
			Engine.time_scale = 0
			fail_window.visible = true

func _on_thrust_button_up():
	thrust_up.emit()

func _on_thrust_button_down():
	thrust_signal.emit()

func _on_left_button_down():
	left_signal.emit()

func _on_left_button_up():
	left_up.emit()

func _on_right_button_down():
	right_signal.emit()

func _on_right_button_up():
	right_up.emit()

func _on_fire_button_down():
	fire_signal.emit()

func _on_fire_button_up():
	fire_up.emit()

func _on_back_pressed():
	pause_window.visible = false
	Engine.time_scale = 1

func _on_exit_pressed():
	get_tree().quit()

func _on_pause_pressed():
	pause_window.visible = true
	Engine.time_scale = 0

func _on_again_pressed():
	Engine.time_scale = 1
	fail_window.visible = false
	get_tree().reload_current_scene()
	
