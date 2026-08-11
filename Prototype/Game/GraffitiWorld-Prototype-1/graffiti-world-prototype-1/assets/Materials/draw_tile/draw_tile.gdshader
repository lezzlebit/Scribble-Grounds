shader_type spatial;

uniform vec3 base_color : source_color = vec3(1.0, 0.9, 0.8);
uniform sampler2D texture_7 : filter_nearest, hint_default_transparent;
uniform sampler2D texture_6 : filter_nearest, hint_default_transparent;
uniform sampler2D texture_5 : filter_nearest, hint_default_transparent;
uniform sampler2D texture_4 : filter_nearest, hint_default_transparent;
uniform sampler2D texture_3 : filter_nearest, hint_default_transparent;
uniform sampler2D texture_2 : filter_nearest, hint_default_transparent;
uniform sampler2D texture_1 : filter_nearest, hint_default_transparent;
uniform sampler2D texture_0 : filter_nearest, hint_default_transparent;

vec4 sample_textures(vec4 base, vec2 uv) {
        vec4 sample = vec4(0.0);
        sample = texture(texture_0, uv);
        base = mix(base, sample, sample.a);
        sample = texture(texture_1, uv);
        base = mix(base, sample, sample.a);
        sample = texture(texture_2, uv);
        base = mix(base, sample, sample.a);
        sample = texture(texture_3, uv);
        base = mix(base, sample, sample.a);
        sample = texture(texture_4, uv);
        base = mix(base, sample, sample.a);
        sample = texture(texture_5, uv);
        base = mix(base, sample, sample.a);
        sample = texture(texture_6, uv);
        base = mix(base, sample, sample.a);
        sample = texture(texture_7, uv);
        base = mix(base, sample, sample.a);
        return base;
}

void vertex() {
	
}


void fragment() {
	vec4 tex = vec4(base_color, 1.0);
	
	tex = sample_textures(tex, UV);
	
	ALBEDO = tex.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
