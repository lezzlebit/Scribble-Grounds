extends Control

class_name UserLog

@export var label_text: Label
var alpha: float = 0

func _init() -> void:
	GlobalGameplayValues.user_log = self

func update_log(text: String):
	alpha = 1
	label_text.text = text
	label_text.self_modulate = Color.WHITE
	
func error(text: String):
	alpha = 1
	label_text.self_modulate = Color.RED
	label_text.text = text

func _process(delta: float) -> void:
	alpha = move_toward(alpha, 0, delta / 2)
	label_text.self_modulate.a = clamp(alpha * 5, 0, 1)
