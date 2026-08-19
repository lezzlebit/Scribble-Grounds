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

#var texture_width: int = GlobalNetworkValues.texture_dimensions.x
#var texture_height: int = GlobalNetworkValues.texture_dimensions.y

var texture_width: int = 1024
var texture_height: int = 1024

var in_undo_selection: bool = false


func _init() -> void:
	
	material_override = get_surface_override_material(0).duplicate()
	texture_material = material_override
	# texture_material.shader = GlobalGameplayValues.draw_tile_shader
	

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

func end_drawing():
	texture_material.set_shader_parameter("selected", -1)


func start_drawing():
	

	var player_username = GlobalNetworkValues.username
	if painted_textures.has(player_username):
		pass
	else:
		var empty_image: Image = Image.create_empty(texture_width, texture_height, false, Image.FORMAT_RGBA8)
		empty_image.fill(Color(1, 1, 1, 0))
		
		set_image(player_username, empty_image)
	
	texture_material.set_shader_parameter("selected", index_of_username(player_username))
	
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
	
	update_undo_values()
	
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
	update_undo_values()

func update_undo_values():
	GlobalGameplayValues.main_camera.raycast.undo_slots = undo_index
	GlobalGameplayValues.main_camera.raycast.redo_slots -= undo_index - undo_buffer.size()

func undo_limit_push():
	undo_buffer = undo_buffer.slice(1, 100, 1)
	undo_index -= 1




func blit_texture(x: float, y: float, paste_image: Image, h: HitData, round_scale: int, erase: bool):
	
	start_drawing()
	var paste_size: Vector2i = Vector2i(paste_image.get_width(), paste_image.get_height())
	
	var draw_behind: bool = !h.should_overwrite
	if erase: draw_behind = false
	
	var previous_image = null
	if draw_behind:
		previous_image = image.duplicate()
	
	var paste_rect = Rect2i(0, 0, paste_size.x, paste_size.y)
	var draw_position = Vector2i(int(texture_width * x), int(texture_height * y))
	draw_position -= paste_size / 2
	draw_position.x = roundi(draw_position.x/round_scale)*round_scale
	draw_position.y = roundi(draw_position.y/round_scale)*round_scale
	
	if erase:
		var erase_color = paste_image.duplicate()
		erase_color.fill(Color.TRANSPARENT)
		image.blit_rect_mask(erase_color, paste_image, paste_rect, draw_position)
	else:
		image.blend_rect(paste_image, paste_rect, draw_position)
	
	
	
	if draw_behind:
		var previous_rect = Rect2i(0, 0, image.get_width(), image.get_height())
		image.blend_rect(previous_image, previous_rect, Vector2i(0, 0))
	
	painted_textures[GlobalNetworkValues.username].update(image)
	

#func fill_spot(x: float, y: float, thickness: float, color: Color, overwrite: bool):
	#var t: float = (thickness * 2) - 1
	#var s: float = (thickness / 2)
	#for xi in range(t):
		#for yi in range(t):
			#
			#var x_addition: float = (float(xi)-s) / float(texture_height)
			#var y_addition: float = (float(yi)-s) / float(texture_width)
			#
			#set_pixel(x+x_addition, y+y_addition, color, overwrite)

func set_pixel(x: float, y: float, color: Color, h: HitData):
	
	start_drawing()
	
	var player_username = GlobalNetworkValues.username
	
	
	
	var drawPos = Vector2i(int(texture_width * x), int(texture_height * y))
	drawPos.x = clampi(drawPos.x, 0, texture_width)
	drawPos.y = clampi(drawPos.y, 0, texture_height)
	
	var should_overwrite: bool = h.should_overwrite
	if color.a == 0: should_overwrite = true
	
	if h.should_overwrite:
		image.set_pixelv(drawPos, color)
	else:
		var alpha = image.get_pixelv(drawPos).a
		if alpha < 0.5: image.set_pixelv(drawPos, color)
	painted_textures[player_username].update(image)
	
