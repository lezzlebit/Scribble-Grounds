extends Node

class_name PlayerColorSetter

@export var color_rect: TextureRect
var color_selected: int = 1

signal on_change

func set_color():
	color_rect.self_modulate = Color.from_string(GlobalGameplayValues.palette_colors[color_selected], Color.BLACK)



func move(amount: int):
	color_selected += amount
	if color_selected < 0:
		color_selected = len(GlobalGameplayValues.palette_colors) - 1
	if color_selected >= len(GlobalGameplayValues.palette_colors):
		color_selected = 0
	set_color()
	on_change.emit()


func _on_prev_pressed(extra_arg_0: int) -> void:
	pass # Replace with function body.
