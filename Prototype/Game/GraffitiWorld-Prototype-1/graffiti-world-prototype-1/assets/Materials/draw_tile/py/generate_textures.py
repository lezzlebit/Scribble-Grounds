

base_function = "\n"

base_function += "vec4 sample_textures(vec4 base, vec2 uv) {\n"
base_function += "	vec4 sample = vec4(0.0);\n"


for i in range(8):
	base_function += "	sample = texture(texture_" + str(i) + ", uv);\n"
	base_function += "	base = mix(base, sample, sample.a);\n"
	base_function = "uniform sampler2D texture_" + str(i) + " : filter_nearest, hint_default_transparent;\n" + base_function

base_function += "	return base;\n}"

print(base_function)