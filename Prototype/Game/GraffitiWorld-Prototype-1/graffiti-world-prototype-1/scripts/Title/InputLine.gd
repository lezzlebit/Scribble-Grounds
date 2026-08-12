extends Control

class_name TitleInputLine

@export var label_text: String
@export var edit_value: String
@export var label: Label
@export var text_input: LineEdit

var text: String:
	get:
		return text_input.text
	set(value):
		text_input.text = value

func _ready() -> void:
	label.text = label_text
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
