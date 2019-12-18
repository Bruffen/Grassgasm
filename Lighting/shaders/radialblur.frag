#version 330

uniform sampler2D tex_source;
uniform sampler2D tex_brightness;
uniform int num_samples;
//uniform vec2 sun_position;

in vec2 uv;

out vec4 o_color;

void main()
{
    vec4 s_color = texture(tex_source, uv);
    float r_color = 0.0;

    vec2 sun_position = vec2(0.5);
    vec2 ray = uv - sun_position;
    vec2 offset = vec2(0.0);

    // Precompute divisions
    float inv_samples = 1.0 / num_samples;
    float inv_samplesn = 1.0 / (num_samples - 1);

    // Sample along ray towards current pixel
    for (int i = 0; i < num_samples; i++) {
        offset = ray * (1 + (-0.9) * i * inv_samplesn);
        r_color += texture(tex_brightness, sun_position + offset).r * inv_samples;
    }

    o_color = s_color + vec4(r_color, r_color, r_color, 0.0);
}