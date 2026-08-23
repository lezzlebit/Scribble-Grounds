extends Node


class_name StoreOption

@export var option_to_store: Control

func _ready() -> void:
	if !get_value(): return
	if option_to_store is HSlider:
		option_to_store.value = float(get_value())
	if option_to_store is Button:
		option_to_store.button_pressed = get_value() == "true"

func get_value():
	UserOptionsSaving.get_file()
	if UserOptionsSaving.options_dictionary.has(option_to_store.name):
		return UserOptionsSaving.options_dictionary[option_to_store.name]
	else:
		return false

func store_with_bool(_was_changed: bool):
	store()

func store():
	
	var value: String = ""
	
	if option_to_store is HSlider:
		value = str(option_to_store.value)
	if option_to_store is Button:
		value = str(option_to_store.button_pressed)
	
	UserOptionsSaving.store(option_to_store.name, value)


func _on_check_box_button_up() -> void:
	pass # Replace with function body.
