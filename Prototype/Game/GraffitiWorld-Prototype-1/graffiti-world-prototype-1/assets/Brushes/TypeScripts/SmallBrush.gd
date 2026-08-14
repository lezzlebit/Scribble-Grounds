extends Brush

class_name SmallBrush

func draw(h: HitData):
	
	
	
	if h.has_last_hit_position:
		draw_line(h)
		
	var coords = UvPosition.get_uv_coords(h.hit_position, h.hit_normal, false)
	h.hit_tile.set_pixel(coords.x, coords.y, h.hit_color, h.should_overwrite_alpha)
	
	pass



func draw_line(h: HitData):
	
	var tile = h.hit_tile
	var should_overwrite_alpha: bool = h.should_overwrite_alpha
	if h.hit_color == Color.TRANSPARENT: should_overwrite_alpha = true
	
	var pos_1 = h.hit_position
	var pos_2 = h.last_hit_position
	
	var distance_requirement: float = 64
	var distance: int = (pos_1.distance_to(pos_2) * distance_requirement) + 5
	distance = clampi(distance, 1, 256)
	
	for i in range(distance):
		var lerpPos: Vector3 = pos_2.lerp(pos_1, float(i)/float(distance))
		var coords = UvPosition.get_uv_coords(lerpPos - tile.position, h.hit_normal, false)
		if !coords:
			return
		tile.set_pixel(coords.x, coords.y, h.hit_color, should_overwrite_alpha)
