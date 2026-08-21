shader_type spatial;
render_mode unshaded, fog_disabled;

varying vec3 world_position;

uniform sampler2D water_lightmap : source_color;
uniform sampler2D water_noise : source_color;
uniform sampler2D screen_noise : source_color;
uniform sampler2D reflection : source_color, repeat_disable;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

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

vec3 soft_light(vec3 base, vec3 blend) {
	vec3 result = vec3(0.0);
	result.r = soft_light_channel(base.r, blend.r);
	result.g = soft_light_channel(base.g, blend.g);
	result.b = soft_light_channel(base.b, blend.b);
	return result;
}


vec3 dither_all(vec2 screen_uv, vec3 colors) {
	
	vec4 noise_sample = texture(screen_noise, screen_uv);
	vec3 result = soft_light(colors.rgb, noise_sample.rgb);
	result = mix(result, colors.rgb, 0.8);
	vec3 simple_result = round(result.rgb * 8.0) / 8.0;
	
	return simple_result;
}

void fragment() {
	
	
	float cam_dist = distance(CAMERA_POSITION_WORLD, world_position) / 2.0;
	
	vec2 uv_1 = (UV * 32.0) + vec2(TIME / 500.0, 0.0);
	vec2 water_noise_sample_1 = texture(water_noise, uv_1).rg;
	water_noise_sample_1 = (water_noise_sample_1 - vec2(0.25, 0.25)) / cam_dist;
	
	vec2 uv_2 = (UV * 128.0) + vec2(0.0, TIME / -50.0);
	vec2 water_noise_sample_2 = texture(water_noise, uv_2 + (water_noise_sample_1 * 1.0)).rg;
	water_noise_sample_2 = (water_noise_sample_2 - vec2(0.25, 0.25)) / cam_dist;
	
	vec2 uv_3 = (UV * 512.0) + vec2(0.0, TIME / -50.0);
	vec2 water_noise_sample_3 = texture(water_noise, uv_3 + (water_noise_sample_1 * -0.5)).rg;
	water_noise_sample_3 = (water_noise_sample_3 - vec2(0.25, 0.25)) / cam_dist;
	
	
	vec2 water_noise_sample = mix(water_noise_sample_2, water_noise_sample_3, 0.4);
	
	vec2 reflection_sample_uv = (SCREEN_UV * vec2(1.0, -1.0)) + (water_noise_sample/2.0) + vec2(0.0, 1.0);
	
	vec4 sampled_reflection = texture(reflection, reflection_sample_uv);
	
	vec4 lightmap_sample = texture(water_lightmap, UV2);
	
	float water_angle = fresnel(3.0, NORMAL, VIEW);
	water_angle = clamp(water_angle, 0.2, 1.0);
	
	
	vec2 screen_resolution = FRAGCOORD.xy / SCREEN_UV;
	vec2 size = vec2(256, 256);
	vec2 aspect = screen_resolution / size;
	vec2 screen_sampler = SCREEN_UV * aspect;
	
	vec3 final_color = mix(sampled_reflection.rgb, lightmap_sample.rgb, 1.0-water_angle);
	// final_color = dither_all(screen_sampler, final_color);
	
	ALBEDO = final_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
