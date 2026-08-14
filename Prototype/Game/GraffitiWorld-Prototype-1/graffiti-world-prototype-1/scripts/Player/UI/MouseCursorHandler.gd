extends Node



func _ready() -> void:
	Input.set_custom_mouse_cursor(preload("res://assets/UI/Cursors/grabbing.png"), Input.CURSOR_DRAG, Vector2(12, 12))
	Input.set_custom_mouse_cursor(preload("res://assets/UI/Cursors/grab.png"), Input.CURSOR_MOVE, Vector2(12, 12))
	Input.set_custom_mouse_cursor(preload("res://assets/UI/Cursors/paint.png"), Input.CURSOR_CROSS, Vector2(16, 16))
	Input.set_custom_mouse_cursor(preload("res://assets/UI/Cursors/pick_color.png"), Input.CURSOR_CAN_DROP, Vector2(10, 18))
	pass
