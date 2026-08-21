shader_type sky;

uniform bool use_screen_coords = false;
uniform sampler2D sky_gradient : source_color;
uniform sampler2D noise_texture : source_color;
uniform sampler2D skybox_texture : source_color;

float soft_light_g(float base) {
	float g = 0.0;
	if (base <= 0.25) {
		g = ((16.0*base-12.0) * base + 4.0) * base;
	} else {
		g = sqrt(base);
	}
	return g;
}
float soft_light_channel(float base, float blend) {
	float result = 0.0;
	float g = soft_light_g(base);
	if (blend <= 0.5) {
		result = base - (1.0 - 2.0*blend)*base*(1.0-base);
	} else {
		result = base + (2.0*blend-1.0)*(g);
	}
	return result;
}




void sky() {
	vec2 screen_resolution = FRAGCOORD.xy / SCREEN_UV;
	
	vec2 size = vec2(256, 256);
	vec2 aspect = screen_resolution / size;
	vec4 noise_sample = texture(noise_texture, SCREEN_UV * aspect);
	
	float noise_influence = mix(noise_sample.r, 1.0, 0.6);
	vec2 coords = SKY_COORDS;
	if (use_screen_coords) {
		coords = SCREEN_UV + vec2(0.0, 0.0);
		float ratio = screen_resolution.x / screen_resolution.y;
		coords *= vec2(ratio, 1.0);
		coords /= vec2(4.0, 2.0);
		coords += vec2(0.1, 0.025);
	}
	float sampled = texture(skybox_texture, coords).r;
	sampled = clamp(sampled, 0.1, 0.95);
	float result = soft_light_channel(sampled, noise_influence) - 0.1455;
	result = round(result * 2.0) / 2.0;
	result = clamp(result, 0.1, 0.95);
	
	COLOR = texture(sky_gradient, vec2(sampled, 0.0)).rgb;
	// COLOR = vec3(sampled);
}
