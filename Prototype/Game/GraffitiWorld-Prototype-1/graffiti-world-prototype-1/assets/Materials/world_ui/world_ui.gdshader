shader_type spatial;
render_mode unshaded;

uniform sampler2D main_texture : source_color;

// https://forum.godotengine.org/t/how-to-do-i-make-a-shader-a-billboard-face-the-player/1980
void vertex() {
    mat4 modified_model_view = VIEW_MATRIX * mat4(
        INV_VIEW_MATRIX[0],
        INV_VIEW_MATRIX[1],
        INV_VIEW_MATRIX[2],
        MODEL_MATRIX[3]
    );
    MODELVIEW_MATRIX = modified_model_view;
}

void fragment() {
	vec4 color = texture(main_texture, UV);
	ALPHA = color.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ALBEDO = color.rgb;
}
