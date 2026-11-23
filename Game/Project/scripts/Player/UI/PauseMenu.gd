extends Control

class_name PauseMenu

var title_scene: PackedScene = load("res://scenes/title/title.tscn")

@export var options_screen: Control

func _ready() -> void:
	pass # Replace with function body.

func toggle_options_visibility():
	options_screen.visible = !options_screen.visible

func unpause():
	options_screen.visible = false
	GlobalGameplayValues.paused = false
	
func load_title():
	GlobalGameplayValues.paused = false
	get_tree().change_scene_to_packed(title_scene)
