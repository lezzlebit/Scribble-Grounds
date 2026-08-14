extends Brush

class_name BlitBrush

@export var shader: Shader
@export var round_position: int = 1

func draw(h: HitData):
	
	var coords = UvPosition.get_uv_coords(h.hit_position, h.hit_normal, false)
	
	blit_texture(h, coords.x, coords.y)
	
	pass
	
func blit_texture(h: HitData, x:float, y:float):
	
	
	
	var blit_viewport: SubViewport = GlobalGameplayValues.main_camera.raycast.blit_viewport
	var color_rect: ColorRect = GlobalGameplayValues.main_camera.raycast.color_rect
	
	color_rect.material.shader = shader
	
	color_rect.color = h.hit_color
	blit_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var image = blit_viewport.get_texture().get_image()
	image.convert(Image.FORMAT_RGBA8)
	
	var is_eraser = h.hit_color == Color.TRANSPARENT
	h.hit_tile.blit_texture(x, y, image, h, round_position, is_eraser)
