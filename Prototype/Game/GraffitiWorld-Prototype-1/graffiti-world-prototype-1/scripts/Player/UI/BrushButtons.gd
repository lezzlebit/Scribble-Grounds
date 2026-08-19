extends Node

class_name BrushButtons

@export var selection_indicator: Control

@export var brush_types: Dictionary[TextureButton, Brush]
@export var default_brush: TextureButton
@export var replace_alpha: TextureButton

func set_brush(pressed_brush: TextureButton):
	GlobalGameplayValues.main_camera.raycast.brush_type = brush_types[pressed_brush]
	selection_indicator.reparent(pressed_brush)
	selection_indicator.position = Vector2.ZERO

func _ready() -> void:
	for i in brush_types:
		i.pressed.connect(set_brush.bind(i))
	pass

func set_color(color: Color):
	for i in brush_types:
		replace_alpha.self_modulate = color
		i.self_modulate = color

func _process(delta: float) -> void:
	pass
