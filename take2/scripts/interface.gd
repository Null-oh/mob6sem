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

func _ready():
	pause_window.visible = false

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
