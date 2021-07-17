shader_type canvas_item;

uniform vec4 banner_mask_color: hint_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform vec4 banner_color: hint_color = vec4(1.0);
uniform float tolerance: hint_range(0.0, 1.0) = .001;

void fragment() {
	vec4 color_a = texture(TEXTURE, UV);
	vec3 color = color_a.rgb;
	float a = color_a.a;
	float mask_len = length(banner_mask_color.rgb);
	float c_len = length(color);
	
	vec3 banner_mask_norm = banner_mask_color.rgb / mask_len * c_len;
	vec3 banner_color_norm = banner_color.rgb / mask_len * c_len;
	
	float dist = distance(color, banner_mask_norm);
	color = mix(banner_color_norm, color, step(tolerance, dist));
	
	COLOR = vec4(color, a);
}