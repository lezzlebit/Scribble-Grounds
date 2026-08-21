extends Node

var title_scene: PackedScene = load("res://scenes/title/title.tscn")

func _ready() -> void:
	pass # Replace with function body.

func unpause():
	GlobalGameplayValues.paused = false
	
func load_title():
	GlobalGameplayValues.paused = false
	get_tree().change_scene_to_packed(title_scene)
