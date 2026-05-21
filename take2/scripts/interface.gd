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
