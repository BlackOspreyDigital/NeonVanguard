shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// Uniforms for customization
uniform float time_scale : hint_range(0.0, 1.0) = 0.05; // Speed of animation
uniform vec3 base_color : source_color = vec3(0.1, 0.3, 0.8); // Neptune blue base
uniform vec3 cloud_color : source_color = vec3(0.6, 0.7, 0.9); // Light blue/white clouds
uniform float cloud_density : hint_range(0.0, 1.0) = 0.6; // Cloud thickness
uniform float cloud_speed : hint_range(0.0, 1.0) = 0.3; // Cloud movement speed
uniform float cloud_scale : hint_range(0.1, 10.0) = 3.0; // Cloud noise scale
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.5; // Atmospheric glow strength
uniform float storm_intensity : hint_range(0.0, 1.0) = 0.3; // Storm pattern strength

// Simple 2D noise function (for procedural clouds)
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) { // Fixed: Corrected parameter name from (header) to p
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    for (int i = 0; i < 6; ++i) {
        v += a * noise(p);
        p = p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void fragment() {
    // UV coordinates scaled for noise detail
    vec2 uv = UV * cloud_scale;
    float time = TIME * time_scale;

    // Base atmosphere layer
    float base_noise = fbm(uv + vec2(time * 0.2, 0.0));
    vec3 atmosphere = base_color * (0.7 + 0.3 * sin(base_noise * 3.14159));

    // Cloud bands layer
    vec2 cloud_uv = uv + vec2(time * cloud_speed, sin(time * 0.1) * 0.1); // Swirling motion
    float cloud_noise = fbm(cloud_uv);
    float clouds = smoothstep(0.2, 0.8, cloud_noise * cloud_density);

    // Storm patterns (darker, turbulent spots)
    vec2 storm_uv = uv + vec2(time * cloud_speed * 0.5, 0.0);
    float storm_noise = fbm(storm_uv + vec2(10.0)); // Offset for variation
    float storms = smoothstep(0.4, 0.6, storm_noise * storm_intensity);

    // Combine layers
    vec3 color = mix(atmosphere, cloud_color, clouds); // Add clouds
    color = mix(color, base_color * 0.7, storms); // Darker storm spots
    ALBEDO = color;
    EMISSION = base_color * glow_intensity * (1.0 - clouds); // Glow through thin clouds
    ALPHA = 1.0; // Opaque surface
}