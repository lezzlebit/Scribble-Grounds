shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;


uniform sampler2D lightmap_texture : source_color;
uniform sampler2D lightmap_noise : source_color;
uniform sampler2D fade_drawing_noise : filter_nearest, hint_default_transparent;
uniform int selected = -1;

// https://www.youtube.com/watch?v=NGCJqLxwQ5c
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




vec4 lightmap_dither(vec2 uv, vec2 screenuv, vec2 resolution) {
	
	vec4 sample = texture(lightmap_texture, uv);
	
	vec2 size = vec2(256, 256);
	vec2 aspect = resolution / size;
	vec4 noise_sample = texture(lightmap_noise, screenuv * aspect);
	vec4 noise_overlay_1 = texture(lightmap_noise, uv * 16.0);
	vec4 noise_overlay_2 = texture(lightmap_noise, uv * 32.0);
	vec4 noise_overlay_3 = texture(lightmap_noise, uv * 64.0);

	vec3 result = mix(sample.rgb, noise_overlay_1.rgb, 0.002);
	result = mix(result.rgb, noise_overlay_2.rgb, 0.002);
	result = mix(result.rgb, noise_overlay_3.rgb, 0.002);
	result = mix(sample.rgb, soft_light(result, noise_sample.rgb), 0.1);
	
	vec3 simple_result = round(result * 64.0) / 64.0;
	
	return vec4(result.rgb, 1.0);
}

float drawing_dither(vec2 screenuv, vec2 resolution, bool round_result) {

	vec2 size = vec2(16, 16);
	vec2 aspect = resolution / size;
	vec4 sample = texture(fade_drawing_noise, screenuv * aspect);
	if (round_result) {
		return clamp(floor(sample.r + 0.25), 0, 1);
	} else {
		return sample.r;
	}
		
}

vec4 single_texture(sampler2D tex, vec2 uv, int selection, int current, vec2 screenuv, vec2 resolution) {
	vec4 current_tex = texture(tex, uv);
	if (selection != -1 && selection != current) {
		current_tex.a *= drawing_dither(screenuv, resolution, true);
	}
	return current_tex;
}



uniform sampler2D texture_15 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_14 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_13 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_12 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_11 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_10 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_9 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_8 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_7 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_6 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_5 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_4 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_3 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_2 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_1 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_0 : filter_nearest, hint_default_transparent, source_color;

vec4 sample_textures(vec4 base, vec2 uv, vec2 screenuv, vec2 resolution) {
        vec4 sample = vec4(0.0);
        sample = single_texture(texture_0, uv, selected, 0, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_1, uv, selected, 1, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_2, uv, selected, 2, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_3, uv, selected, 3, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_4, uv, selected, 4, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_5, uv, selected, 5, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_6, uv, selected, 6, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_7, uv, selected, 7, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_8, uv, selected, 8, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_9, uv, selected, 9, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_10, uv, selected, 10, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_11, uv, selected, 11, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_12, uv, selected, 12, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_13, uv, selected, 13, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_14, uv, selected, 14, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_15, uv, selected, 15, screenuv, resolution);
        base = mix(base, sample, sample.a);
        return base;
}


void vertex() {
	
}

vec4 dither_lighting(vec4 lightmap_sampled) {
	return round(lightmap_sampled * 32.0) / 32.0;
}

float dither_fog(float input, vec2 screenuv, vec2 resolution) {
	vec2 size = vec2(256, 256);
	vec2 aspect = resolution / size;
	vec4 sample = texture(lightmap_noise, screenuv * aspect);
	return soft_light_channel(input, sample.r);
}


void fragment() {
	vec4 tex = vec4(vec3(1.0), 0.0);
	
	vec2 screen_resolution = FRAGCOORD.xy / SCREEN_UV;
	
	tex = sample_textures(tex, UV, SCREEN_UV, screen_resolution);
	
	float z_near = abs(PROJECTION_MATRIX[3][2] / PROJECTION_MATRIX[2][2]);
	float z_far = abs((PROJECTION_MATRIX[3][2] * z_near) / (PROJECTION_MATRIX[3][2] + z_near));
	float fragment_depth = FRAGCOORD.z;
	
	float depth = dither_fog(fragment_depth * (z_near), SCREEN_UV, screen_resolution);
	
	vec4 lightmap = lightmap_dither(UV2, SCREEN_UV, screen_resolution);
	
	
	vec3 result = tex.rgb * lightmap.rgb;
	if (!FRONT_FACING) {
		result = vec3(0.0);
	}
	
	
	ALBEDO = result.rgb;
}

//void light() {
	//
	//if (LIGHT_IS_AREA) {
		//DIFFUSE_LIGHT += LIGHT_COLOR * LIGHT_AREA_DIFFUSE_MULTIPLIER;
	//}
	//
	//vec2 screen_resolution = FRAGCOORD.xy / SCREEN_UV;
	//float dither = (noise_dither(SCREEN_UV, screen_resolution, false) - 0.5) * 0.1;
	//float light_dither = ATTENUATION + dither;
	//light_dither = clamp(round(light_dither), 0.0, 1.0);
	//
	//SPECULAR_LIGHT = vec3(0.0);
	//DIFFUSE_LIGHT = vec3(1.0);
//}
