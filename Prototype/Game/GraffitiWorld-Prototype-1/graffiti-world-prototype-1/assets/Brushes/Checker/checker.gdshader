shader_type canvas_item;

uniform vec4 brush_color;
uniform vec2 brush_position;

void vertex() {

}

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	
	
	float radius = 0.5;
	float sample_distance = distance(UV, vec2(0.5, 0.5));
	
	float vertical_lines = sin(UV.y * 11.0 * PI);
	float horizontal_lines = sin(UV.x * 11.0 * PI);
	float checker_sample = abs(vertical_lines - horizontal_lines);
	
	float random_uv = random(UV + vec2(TIME, 1.0)) * 10.0;
	
	float alpha_threshold = 1.0-floor((sample_distance / radius) + random_uv);
	
	COLOR = vec4(COLOR.rgb, checker_sample * alpha_threshold);
}
