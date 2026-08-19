extends Control

class_name PaletteButtons

@export var selection_indicator: Control
@export var palette_button_scene: PackedScene
@export var button_parent: Control
@export var eraser: TextureButton
@export var brush_buttons: BrushButtons
@export var replace_color: TextureButton
@export var alpha_replace_mode_text: Label
@export var alpha_replace_mode_selector: Control
@export var mute_on_selection: Array[Control]
@export var undo_button: TextureButton
@export var redo_button: TextureButton

var selecting_replace_color: bool = false

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
	
	GlobalGameplayValues.drawing_controls = self
	
	for i in range(len(colors)):
		var new_button = palette_button_scene.instantiate()
		button_parent.add_child(new_button)
		button_parent.move_child(new_button, 0)
		
		var button_object: TextureButton = new_button as TextureButton
		button_object.self_modulate = Color.from_string(colors[i], Color.WHITE)
		button_object.pressed.connect(set_color.bind(i))
		all_buttons.append(button_object)
	all_buttons.append(eraser)
	set_color(1)

func set_replace_color():
	
	GlobalGameplayValues.main_camera.picking_color_for_replace = true
	for i in mute_on_selection:
		i.modulate = Color(0.8, 0.8, 0.8, 0.5)
		i.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	
	for i in all_buttons:
		i.mouse_default_cursor_shape = Control.CURSOR_CAN_DROP
	
	selection_indicator.visible = false
	selecting_replace_color = true

func update_undo_buttons(undo: int, redo: int):
	print(undo)
	undo_button.disabled = undo < 1
	redo_button.disabled = redo <= 1

func end_replace_color():
	
	GlobalGameplayValues.main_camera.picking_color_for_replace = false
	for i in mute_on_selection:
		i.modulate = Color.WHITE
		i.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	for i in all_buttons:
		i.mouse_default_cursor_shape = Control.CURSOR_ARROW
		
	selection_indicator.visible = true

func set_replace_mode(replace_on: bool):
	alpha_replace_mode_selector.visible = replace_on
	if replace_on: alpha_replace_mode_text.text = "Drawing Under"
	if !replace_on: alpha_replace_mode_text.text = "Drawing Over"
	GlobalGameplayValues.main_camera.raycast.should_overwrite = !replace_on
	# replace_color.visible = replace_on

func set_erase():
	if selecting_replace_color:
		replace_color.texture_normal = eraser.texture_normal
		replace_color.self_modulate = Color.WHITE
		selecting_replace_color = false
		end_replace_color()
		return
	selection_indicator.reparent(eraser)
	selection_indicator.position = Vector2.ZERO
	GlobalGameplayValues.main_camera.raycast.current_color = Color.TRANSPARENT
	brush_buttons.set_color(Color.WHITE)

func set_color(color_id: int):
	if selecting_replace_color:
		replace_color.texture_normal = all_buttons[color_id].texture_normal
		replace_color.self_modulate = all_buttons[color_id].self_modulate
		selecting_replace_color = false
		end_replace_color()
		return
	selection_indicator.reparent(all_buttons[color_id])
	selection_indicator.position = Vector2.ZERO
	GlobalGameplayValues.main_camera.raycast.current_color = colors[color_id]
	brush_buttons.set_color(colors[color_id])
	

func _process(delta: float) -> void:
	pass
