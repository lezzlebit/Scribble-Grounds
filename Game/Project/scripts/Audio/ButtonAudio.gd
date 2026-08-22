extends Node


var all_buttons: Array[Button]
signal on_press_any
signal on_unpress_any

func get_all_children(node):
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)
	return nodes

func _ready() -> void:
	connect_buttons_to_audio()

func connect_buttons_to_audio() -> void:
	for i in get_all_children(self):
		if (i is Button) and !all_buttons.has(i as Button):
			all_buttons.append(i as Button)
			if i.toggle_mode:
				i.toggled.connect(toggle_button)
			else:
				i.button_down.connect(press_button)
		if i is TextureButton:
			if i.toggle_mode:
				i.toggled.connect(toggle_button)
			else:
				i.button_down.connect(press_button)
	pass

func toggle_button(on: bool):
	if on:
		press_button()
	else:
		unpress_button()

func unpress_button():
	on_unpress_any.emit()

func press_button():
	on_press_any.emit()
