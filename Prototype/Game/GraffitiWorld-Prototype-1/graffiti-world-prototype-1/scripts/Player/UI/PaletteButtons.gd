extends Control

class_name PaletteButtons

@export var selection_indicator: Control
@export var palette_button_scene: PackedScene
@export var button_parent: Control
@export var eraser: TextureButton
@export var brush_buttons: BrushButtons

var colors: Array[String] = [
	"#ffffff","#000000",
	"#1c3c00","#581931","#2a005f", 
	"#008738","#c6082a","0009e8",
	"#88a671","#ff257d","#625ab5",
	"#00ff3d","#ff622e","#1e7dff",
	"#9fff7f","#ff81a6","#96c2ff",
	"#7e4b1b","#214c48","#3d2d43",
	"#e47a00","#227491","#822eb3",
	"#c4a77e","#67998a","#905999",
	"#ffe42b","#44ffe6","#ff26f2",
	"#fff39e","#baffc3","#ff9abf"]

var all_buttons: Array[TextureButton]

func _ready() -> void:
	
	
	for i in range(len(colors)):
		var new_button = palette_button_scene.instantiate()
		button_parent.add_child(new_button)
		button_parent.move_child(new_button, 0)
		
		var button_object: TextureButton = new_button as TextureButton
		button_object.self_modulate = Color.from_string(colors[i], Color.WHITE)
		button_object.pressed.connect(set_color.bind(i))
		all_buttons.append(button_object)
	set_color(1)

func set_erase():
	selection_indicator.reparent(eraser)
	selection_indicator.position = Vector2.ZERO
	GlobalGameplayValues.main_camera.raycast.current_color = Color.TRANSPARENT
	brush_buttons.set_color(Color.WHITE)

func set_color(color_id: int):
	selection_indicator.reparent(all_buttons[color_id])
	selection_indicator.position = Vector2.ZERO
	GlobalGameplayValues.main_camera.raycast.current_color = colors[color_id]
	brush_buttons.set_color(colors[color_id])

func _process(delta: float) -> void:
	pass
