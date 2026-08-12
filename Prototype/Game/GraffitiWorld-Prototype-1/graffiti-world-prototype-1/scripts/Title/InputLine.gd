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
	text_input.text_changed.connect(correct_input)

func correct_input(new_text):
	var input_pos = text_input.caret_column
	var input: String = new_text
	var unwanted = ['/','=','?',"\n"]
	for i in unwanted:
		input = input.replace(i, "")
	text_input.text = input
	text_input.caret_column = input_pos
