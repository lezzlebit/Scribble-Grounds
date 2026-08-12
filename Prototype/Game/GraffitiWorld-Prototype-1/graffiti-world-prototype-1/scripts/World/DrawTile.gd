extends MeshInstance3D

class_name DrawTile



var username_index: Array[String]
var painted_textures: Dictionary[String, ImageTexture]

var image : Image
var image_texture : ImageTexture
var texture_material: ShaderMaterial

var undo_index: int = 0
var undo_buffer: Array[Image]
var full_buffer_storage: Array[Image]

var texture_width: int = 512
var texture_height: int = 512

var in_undo_selection: bool = false


func _init() -> void:
	
	texture_material = ShaderMaterial.new()
	texture_material.shader = GlobalGameplayValues.draw_tile_shader
	material_override = texture_material
	

func index_of_username(username_in: String):
	for i in range(username_index.size()):
		if username_index[i] == username_in:
			return i
	return null

func check_add_username_to_index(username_in: String):
	if !username_index.has(username_in):
		username_index.append(username_in)

func set_image(image_username: String, set_image: Image):
	print("Updated " + name)
	
	check_add_username_to_index(image_username)
	painted_textures[image_username] = ImageTexture.create_from_image(set_image)
	painted_textures[image_username].update(set_image)
	
	# print(image_username + " - " + str(index_of_username(image_username)))
	
	
	texture_material.set_shader_parameter("texture_" + str(index_of_username(image_username)), painted_textures[image_username])

func start_drawing():
	var player_username = GlobalNetworkValues.username
	if painted_textures.has(player_username):
		pass
	else:
		var empty_image: Image = Image.create_empty(texture_width, texture_height, false, Image.FORMAT_RGBA8)
		empty_image.fill(Color(1, 1, 1, 0))
		
		set_image(player_username, empty_image)
	
	if image == null:
		image = painted_textures[player_username].get_image()

func clear_undo_buffer():
	undo_buffer = undo_buffer.slice(0, 0, 1)
	undo_index = 0

func add_undo():
	
	if image == null:
		start_drawing()
	

	undo_buffer = undo_buffer.slice(0, undo_index, 1)
	undo_index += 1
	undo_buffer.append(image.duplicate())
	
	if undo_index > GlobalGameplayValues.undo_limit:
		undo_limit_push()
	
	in_undo_selection = false
	
func move_undo(index: int):
	
	if !in_undo_selection:
		if index == -1: 
			add_undo()
			undo_index -= 1
		
		in_undo_selection = true
	
	var player_username = GlobalNetworkValues.username
	var new_undo_index = undo_index + index
	
	if new_undo_index >= 0 and new_undo_index < undo_buffer.size():
		undo_index = new_undo_index
		
		var undo_image: Image = undo_buffer[undo_index]
		image = undo_image
		painted_textures[player_username].update(image)

func undo_limit_push():
	undo_buffer = undo_buffer.slice(1, 100, 1)
	undo_index -= 1




func set_pixel(x: float, y: float):
	
	start_drawing()
	
	var player_username = GlobalNetworkValues.username
	
	
	
	var drawPos = Vector2i(int(texture_width * x), int(texture_height * y))
	image.set_pixelv(drawPos, Color.BLUE)
	painted_textures[player_username].update(image)

func _process(delta: float) -> void:
	pass
	
