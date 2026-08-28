extends Node

var first_person: bool = true
var load_model: LoadModel = null
var player_controller: PlayerMovement = null
var main_camera: CameraController = null
var network_handler: NetworkHandler = null
var world_textures: WorldTextures = null
var user_log: UserLog = null
var draw_tile_shader: Shader = preload("res://assets/Materials/draw_tile/draw_tile.gdshader")
var paused: bool = false
var drawing_controls: PaletteButtons = null
var camera_sensitivity: float = 0

var undo_limit = 16

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
