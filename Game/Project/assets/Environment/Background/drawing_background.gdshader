shader_type sky;

uniform sampler2D checker_texture : source_color, filter_nearest;
uniform vec3 bright : source_color;
uniform vec3 dark : source_color;

void sky() {
	vec2 screen_resolution = FRAGCOORD.xy / SCREEN_UV;
	vec2 size = vec2(16, 16) * 8.0;
	vec2 aspect = screen_resolution / size;
	float checker_sample = texture(checker_texture, SCREEN_UV * aspect).r;
	COLOR = mix(bright, dark, checker_sample);
}
