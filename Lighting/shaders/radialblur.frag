#version 330

uniform sampler2D tex_source;
uniform sampler2D tex_brightness;
uniform int num_samples;
uniform float ray_length;
//uniform vec2 sun_position;

in vec2 uv;

out vec4 o_color;

void main()
{
    vec4 s_color = texture(tex_source, uv);
    float ray_alpha = 0.0;

    vec2 sun_position = vec2(0.5);
    vec2 ray_distance = uv - sun_position;
    vec2 offset = vec2(0.0);

    // Precompute division
    float inv_numsamples = 1.0 / num_samples;

    // Sample along center of sun towards current pixel
    for (int i = 0; i < num_samples; i++) {
        offset = ray_distance * (1 - ray_length * (i * inv_numsamples));
        ray_alpha += texture(tex_brightness, sun_position + offset).r * inv_numsamples;
    }

    o_color = mix(s_color, vec4(1.0, 1.0, 0.9, 1.0), ray_alpha);
    //o_color = vec4(ray_alpha);
}