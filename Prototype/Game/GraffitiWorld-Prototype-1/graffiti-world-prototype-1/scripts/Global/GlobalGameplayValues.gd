extends Node

var first_person: bool = true
var main_camera: CameraController = null
var network_handler: NetworkHandler = null
var world_textures: WorldTextures = null
var user_log: UserLog = null
var draw_tile_shader: Shader = preload("res://assets/Materials/draw_tile/draw_tile.gdshader")

var standard_texture_size: int = 512

var undo_limit = 8

func user_error_log(log: String):
	user_log.update_log(log)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
