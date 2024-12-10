shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

const float curvature = 100.0;
const float vignette_multiplier = 0.33;
const float scanlines_multiplier = 0.06;
const float scanlines_brightness_offset = 0.33;
const float blur_intensity = 0.003;
const int blur_samples = 2;
const float blur_decay = 3.0;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
    vec2 uv_offset = centered_uv.yx / curvature;
    vec2 warped_uv = centered_uv + centered_uv * uv_offset * uv_offset;
    vec3 cutoff = vec3(step(abs(warped_uv.x), 1.0) * step(abs(warped_uv.y), 1.0));
    vec3 scanlines = vec3(sin(2.0 * warped_uv.y * (648.0 / 2.0)) * scanlines_multiplier + scanlines_brightness_offset);
    vec3 vignette = vec3(length(pow(abs(centered_uv), vec2(4.0)) / 3.0));

    vec3 screen_color = vec3(0.0);
    float total_weight = 0.0;

    // Sample the texture multiple times with offsets to the right
    for (int i = 0; i < blur_samples; i++) {
        float offset = float(i) * blur_intensity;
        vec2 sample_uv = (warped_uv + vec2(offset, 0.0) + 1.0) / 2.0;
        float weight = pow(blur_decay, float(i));
        vec3 sample_color = textureLod(screen_texture, sample_uv, 0.0).rgb * weight;

        screen_color = mix(screen_color, sample_color, weight / (total_weight + weight));
        total_weight += weight;
    }

    screen_color *= cutoff * scanlines;
    screen_color -= vignette * vignette_multiplier;
    COLOR = vec4(screen_color, 1.0);
}
