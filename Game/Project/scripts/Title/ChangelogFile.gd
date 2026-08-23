extends RichTextLabel



func _ready() -> void:
	var file_text = FileAccess.open("res://changelog.txt", FileAccess.READ).get_as_text()
	text = file_text
	pass 
