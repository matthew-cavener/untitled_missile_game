shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

const float curvature = 7.0;
const float vignette_multiplier = 0.5;
const float scanlines_multiplier = 0.25;
const float scanlines_brightness_offset = 0.75;
const float blur_value = 0.3;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
    vec2 uv_offset = centered_uv.yx / curvature;
    vec2 warped_uv = centered_uv + centered_uv * uv_offset * uv_offset;
    vec3 cutoff = vec3(step(abs(warped_uv.x), 1.0) * step(abs(warped_uv.y), 1.0));
    vec3 scanlines = vec3(sin(2.0 * warped_uv.y * (648.0 / 3.0)) * scanlines_multiplier + scanlines_brightness_offset);
    vec3 vignette = vec3(length(pow(abs(centered_uv), vec2(4.0)) / 3.0));

    vec3 screen_color = textureLod(screen_texture, (warped_uv + 1.0) / 2.0, blur_value).rgb * cutoff * scanlines;
    screen_color -= vignette * vignette_multiplier;
    // COLOR = vec4(warped_uv, 0.0, 1.0);
    COLOR = vec4(screen_color, 1.0);
}
