extends Node

var first_person: bool = true
var load_model: LoadModel = null
var player_controller: PlayerMovement = null
var main_camera: CameraController = null
var reflection_camera: WaterReflectionCamera
var network_handler: NetworkHandler = null
var world_textures: WorldTextures = null
var user_log: UserLog = null
var draw_tile_shader: Shader = preload("res://assets/Materials/draw_tile/draw_tile.gdshader")
var paused: bool = false
var drawing_controls: PaletteButtons = null
var footsteps: FootstepHandler = null
var camera_sensitivity: float = 0
var use_footsteps: bool = false
var viewing_offline: bool = false
var playing_locally: bool = false
var sprint_is_toggle: bool = false

var undo_limit = 16

var palette_colors: Array[String] = [
"ffffff","000000","1c3c00",
"581931","2a005f","008738",
"b00020","0009e8","88a671",
"fd0368","625ab5","00e637",
"ff622e","1e7dff","9fff7f",
"ff81a6","96c2ff","725335",
"214c48","3d2d43","957a5b",
"227491","822eb3","ff9d4e",
"6d9e8f","905999","ffe42b",
"06e7c9","ff26f2","fff39e",
"baffc3","df7dff"]

func set_palette(new_palette: String):

	new_palette = new_palette.replace("\n", "")
	var new_palette_colors: PackedStringArray = new_palette.split(",")
	var converted_palette_colors: Array[String]
	for i in new_palette_colors:
		if Color.html_is_valid(i):
			converted_palette_colors.append(i)
	if converted_palette_colors.size() > 0:
		palette_colors = converted_palette_colors

func user_message_log(log: String):
	user_log.update_log(log)
	pass

func user_error_log(log: String):
	user_log.error(log)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
