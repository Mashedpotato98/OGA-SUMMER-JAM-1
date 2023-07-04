shader_type canvas_item;

uniform vec3 color = vec3(1.0, 1.0, 1.0);
uniform bool enabled = false;

void fragment() {
	vec4 old_color = texture(TEXTURE, UV);
	if (enabled) {
		COLOR = vec4(color, old_color.a);
	} else {
		COLOR = old_color;
	}
}
