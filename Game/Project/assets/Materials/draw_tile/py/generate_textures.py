

base_function = "\n"

base_function += "vec4 sample_textures(vec4 base, vec2 uv, vec2 screenuv, vec2 resolution) {\n"
base_function += "	vec4 sample = vec4(0.0);\n"

tex_count = 64

for value in range(tex_count + 1):

	name = value
	i = value

	base_function += "	sample = single_texture(texture_" + str(name) + ", uv, selected, " + str(i) + ", screenuv, resolution);\n"
	base_function += "	base = mix(base, sample, sample.a);\n"
	base_function = "uniform sampler2D texture_" + str(name) + " : filter_nearest, hint_default_transparent, source_color;\n" + base_function

base_function += "	return base;\n}"

print(base_function)