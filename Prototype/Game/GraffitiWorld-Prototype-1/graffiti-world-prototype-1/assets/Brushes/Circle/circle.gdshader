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
	
	
	float random_value = random(vec2(TIME, 1.0));
	float radius = 0.5 * random_value;
	float sample_distance = distance(UV, vec2(0.5, 0.5));
	float alpha_threshold = 1.0-floor(sample_distance / radius);
	
	COLOR = vec4(COLOR.rgb, alpha_threshold);
}
