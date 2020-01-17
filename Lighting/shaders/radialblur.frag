#version 330

uniform sampler2D tex_source;
uniform sampler2D tex_brightness;
uniform int num_samples;
uniform float ray_length;
uniform vec3 sun_color;
uniform vec2 sun_screenPos;

in data {
	vec2 	uv;
} o;

out vec4 o_color;

void main()
{
    vec4 s_color = texture(tex_source, o.uv);
    vec2 ray_distance = o.uv - sun_screenPos;

    // Precompute loop values
    float inv_numsamples = 1.0 / num_samples;
    float ray_alpha = 0.0;
    vec2 offset = vec2(0.0);

    // Sample along center of sun towards current pixel
    for (int i = 0; i < num_samples; i++) {
        offset = ray_distance * (1 - ray_length * (i * inv_numsamples));
        ray_alpha += texture(tex_brightness, sun_screenPos + offset).r * inv_numsamples;
    }

    o_color = mix(s_color, vec4(sun_color, 1.0), ray_alpha);
    //o_color = vec4(pvm[1][2]) * 0.8;
}