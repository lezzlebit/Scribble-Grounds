shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_disabled;

varying vec3 world_position;

uniform bool backside_obscured;

uniform sampler2D vertex_texture : source_color, hint_default_white;
uniform sampler2D lightmap_texture : source_color;
uniform sampler2D lightmap_noise : source_color;
uniform sampler2D fade_drawing_noise : filter_nearest, hint_default_transparent;
uniform sampler2D texture_footsteps : filter_linear, source_color;
uniform int selected = -1;
const float texture_count = 65.0;
const int texture_scale = 1024;

global uniform bool lightmap_disabled;

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




vec4 lightmap_dither(vec2 uv, vec2 screenuv, vec2 resolution, vec4 vcolor) {
	
	vec4 sample = texture(lightmap_texture, uv);
	vec4 vertex_texture_sampled = mix(texture(vertex_texture, vec2(1.0)-vcolor.rg), vec4(1.0), vcolor.b);
	sample *= vertex_texture_sampled;
	
	vec2 size = vec2(256, 256);
	vec2 aspect = resolution / size;
	vec4 noise_sample = texture(lightmap_noise, screenuv * aspect);
	vec4 noise_overlay_1 = texture(lightmap_noise, uv * 16.0);
	vec4 noise_overlay_2 = texture(lightmap_noise, uv * 32.0);
	vec4 noise_overlay_3 = texture(lightmap_noise, uv * 64.0);

	vec3 result = mix(sample.rgb, noise_overlay_1.rgb, 0.005);
	result = mix(result.rgb, noise_overlay_2.rgb, 0.008);
	result = mix(result.rgb, noise_overlay_3.rgb, 0.008);
	// result = mix(result.rgb, soft_light(result, noise_sample.rgb), 0.4);
	
	// vec3 simple_result = round(result * 16.0) / 16.0;
	
	return vec4(sample.rgb, 1.0);
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
	current_tex.a *= (1.0/texture_count);
	return current_tex;
}



uniform sampler2D texture_64 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_63 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_62 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_61 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_60 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_59 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_58 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_57 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_56 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_55 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_54 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_53 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_52 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_51 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_50 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_49 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_48 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_47 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_46 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_45 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_44 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_43 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_42 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_41 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_40 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_39 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_38 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_37 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_36 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_35 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_34 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_33 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_32 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_31 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_30 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_29 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_28 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_27 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_26 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_25 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_24 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_23 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_22 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_21 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_20 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_19 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_18 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_17 : filter_nearest, hint_default_transparent, source_color;
uniform sampler2D texture_16 : filter_nearest, hint_default_transparent, source_color;
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
        base = mix(base, sample, sample.a);
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
        sample = single_texture(texture_16, uv, selected, 16, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_17, uv, selected, 17, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_18, uv, selected, 18, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_19, uv, selected, 19, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_20, uv, selected, 20, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_21, uv, selected, 21, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_22, uv, selected, 22, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_23, uv, selected, 23, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_24, uv, selected, 24, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_25, uv, selected, 25, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_26, uv, selected, 26, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_27, uv, selected, 27, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_28, uv, selected, 28, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_29, uv, selected, 29, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_30, uv, selected, 30, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_31, uv, selected, 31, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_32, uv, selected, 32, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_33, uv, selected, 33, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_34, uv, selected, 34, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_35, uv, selected, 35, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_36, uv, selected, 36, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_37, uv, selected, 37, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_38, uv, selected, 38, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_39, uv, selected, 39, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_40, uv, selected, 40, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_41, uv, selected, 41, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_42, uv, selected, 42, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_43, uv, selected, 43, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_44, uv, selected, 44, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_45, uv, selected, 45, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_46, uv, selected, 46, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_47, uv, selected, 47, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_48, uv, selected, 48, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_49, uv, selected, 49, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_50, uv, selected, 50, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_51, uv, selected, 51, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_52, uv, selected, 52, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_53, uv, selected, 53, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_54, uv, selected, 54, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_55, uv, selected, 55, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_56, uv, selected, 56, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_57, uv, selected, 57, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_58, uv, selected, 58, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_59, uv, selected, 59, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_60, uv, selected, 60, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_61, uv, selected, 61, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_62, uv, selected, 62, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_63, uv, selected, 63, screenuv, resolution);
        base = mix(base, sample, sample.a);
        sample = single_texture(texture_64, uv, selected, 64, screenuv, resolution);
        base = mix(base, sample, sample.a);
        return base;
}


void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
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


vec4 sample_footsteps(vec2 uv, vec2 screenuv, vec2 resolution) {
	
	float tex_size = float(texture_scale);
	
	uv.x = floor(uv.x * tex_size) / tex_size;
	uv.y = floor(uv.y * tex_size) / tex_size;
	
	vec4 sampled_footsteps = texture(texture_footsteps, uv);
	float sampled_noise = texture(lightmap_noise, uv).r;
	sampled_noise = mix(sampled_noise, 1.0, 0.3);
	sampled_footsteps *= sampled_noise;
	
	if (sampled_footsteps.a > 0.0) {
		sampled_footsteps.rgb /= sampled_footsteps.a;
	}
	//
	sampled_footsteps.a = ceil(sampled_footsteps.a - 0.3);
	sampled_footsteps.a = clamp(sampled_footsteps.a, 0.0, 1.0);
	
	sampled_footsteps.rgb = round(sampled_footsteps.rgb * 8.0) / 8.0;
	
	sampled_footsteps.a *= drawing_dither(screenuv, resolution, true);
	
	vec4 bg = vec4(0.0);
	
	
	
	vec4 result = mix(bg, sampled_footsteps, sampled_footsteps.a);
	
	return result;
}


void fragment() {
	vec4 tex = vec4(vec3(0.0), 0.0);
	
	vec2 screen_resolution = FRAGCOORD.xy / SCREEN_UV;
	
	tex = sample_textures(tex, UV, SCREEN_UV, screen_resolution);
	if (tex.a > 0.0) {
		tex.rgb /= (tex.a * texture_count);
		tex.a = 1.0;
	}
	
	//tex.a = ceil(tex.a);
	
	float z_near = abs(PROJECTION_MATRIX[3][2] / PROJECTION_MATRIX[2][2]);
	float z_far = abs((PROJECTION_MATRIX[3][2] * z_near) / (PROJECTION_MATRIX[3][2] + z_near));
	float fragment_depth = FRAGCOORD.z;
	
	float depth = dither_fog(fragment_depth * (z_near), SCREEN_UV, screen_resolution);
	
	vec4 lightmap = lightmap_dither(UV2, SCREEN_UV, screen_resolution, COLOR);
	if (lightmap_disabled) {
		lightmap = vec4(1.0);
	}
	// vec4 lightmap = texture(lightmap_texture, UV2);
	
	vec4 footsteps_sampled = sample_footsteps(UV, SCREEN_UV, screen_resolution);
	tex = mix(footsteps_sampled, tex, tex.a);
	
	vec3 result = mix(lightmap.rgb, tex.rgb * lightmap.rgb, tex.a);
	// result = vec3(tex.a);
	vec3 overlay = mix(lightmap.rgb, tex.rgb, tex.a);
	result = mix(result.rgb, overlay, 0.15);


	
	vec4 vertex_texture_sampled = mix(texture(vertex_texture, vec2(1.0)-COLOR.rg), vec4(1.0), COLOR.b);
	
	ALPHA = vertex_texture_sampled.a;
	
	
	
	if (world_position.y < -32.0) {
		ALPHA = 0.0;
	}
	
	if (!FRONT_FACING && backside_obscured) {
		result = vec3(0.0);
		ALPHA = 0.0;
	}
	
	ALPHA_SCISSOR_THRESHOLD = 0.5;
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
