shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// Uniforms for customization
uniform float time_scale : hint_range(0.0, 1.0) = 0.1; // Line 5: Speed of animation
uniform vec3 fire_color : source_color = vec3(1.0, 0.3, 0.1); // Line 6: Base fire color (red-orange)
uniform vec3 glow_color : source_color = vec3(1.0, 0.7, 0.2); // Line 7: Glow color (yellow-orange)
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0; // Line 8: Glow strength
uniform float cloud_density : hint_range(0.0, 1.0) = 0.5; // Line 9: Cloud thickness
uniform float cloud_speed : hint_range(0.0, 1.0) = 0.2; // Line 10: Cloud movement speed
uniform float cloud_scale : hint_range(0.1, 10.0) = 2.0; // Line 11: Cloud noise scale

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

float fbm(vec2 p) {
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
    // Use UV coordinates and time for animation
    vec2 uv = UV * cloud_scale;
    float time = TIME * time_scale;

    // Fire base layer
    float fire_noise = fbm(uv + vec2(time * 0.5, 0.0));
    vec3 fire = fire_color * (0.5 + 0.5 * sin(fire_noise * 3.14159 + time));
    vec3 glow = glow_color * glow_intensity * (0.5 + 0.5 * sin(fire_noise * 2.0 + time));

    // Cloud layer
    vec2 cloud_uv = uv + vec2(time * cloud_speed, 0.0);
    float cloud_noise = fbm(cloud_uv);
    float clouds = smoothstep(0.3, 0.7, cloud_noise * cloud_density);

    // Combine layers
    vec3 color = mix(fire + glow, vec3(0.8, 0.8, 0.9), clouds); // Clouds are light gray
    ALBEDO = color;
    EMISSION = glow * (1.0 - clouds); // Glow only where clouds are thin
    ALPHA = 1.0; // Opaque surface
}