shader_type spatial;
render_mode blend_mix, depth_test_disabled;

uniform float grid_size = 1.0; // Size of each grid cell
uniform float cross_size = 0.2; // Size of plus-shaped crosshairs
uniform vec4 cross_color : source_color = vec4(0.0, 1.0, 1.0, 0.8); // Neon cyan
uniform vec4 background_color : source_color = vec4(0.1, 0.1, 0.2, 0.2); // Dark semi-transparent

void fragment() {
    vec2 uv = UV * 20.0 / grid_size;
    vec2 grid = fract(uv);
    vec2 dist = abs(grid - 0.5);
    // Draw plus shape: horizontal and vertical lines centered at grid points
    float cross = step(dist.x, cross_size / 10.0) * step(dist.y, cross_size / grid_size) +
                  step(dist.y, cross_size / 10.0) * step(dist.x, cross_size / grid_size);
    ALBEDO = mix(cross_color.rgb, background_color.rgb, 1.0 - cross);
    ALPHA = mix(cross_color.a, background_color.a, 1.0 - cross);
}