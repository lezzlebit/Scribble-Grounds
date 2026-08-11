extends MeshInstance3D

class_name DrawTile


var image : Image
var image_texture : ImageTexture
var texture_material: ShaderMaterial

var texture_width: int = 512
var texture_height: int = 512


func _init() -> void:
	
	texture_material = ShaderMaterial.new()
	texture_material.shader = GlobalGameplayValues.draw_tile_shader
	
	image = Image.create_empty(texture_width, texture_height, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 0))
	material_override = texture_material
	image_texture = ImageTexture.create_from_image(image)
	texture_material.set_shader_parameter("texture_0",image_texture)
	

func set_image(set_image: Image):
	print("Updated " + name)
	
	
	image = set_image
	
	image_texture = ImageTexture.create_from_image(image)
	print(image.get_pixel(0, 0))
	
	
	image_texture.update(image)
	texture_material.set_shader_parameter("texture_0",image_texture)

func set_pixel(x: float, y: float):
	
	var world_textures: WorldTextures = GlobalGameplayValues.world_textures
	if !world_textures.painted_tiles.has(self):
		world_textures.painted_tiles.append(self)
	
	var drawPos = Vector2i(int(texture_width * x), int(texture_height * y))
	image.set_pixelv(drawPos, Color.BLUE)
	image_texture.update(image)

func _process(delta: float) -> void:
	pass
	
