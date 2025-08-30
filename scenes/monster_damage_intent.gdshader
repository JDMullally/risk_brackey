shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(.7, 0.0, 0.0, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = vec4(tex_color.rgb * tint_color.rgb, tex_color.a * tint_color.a);
}