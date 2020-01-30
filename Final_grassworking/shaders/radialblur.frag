#version 430

uniform sampler2D tex_source;
uniform sampler2D tex_brightness;
uniform sampler2D tex_lensflare;
uniform int num_samples;
uniform float ray_length;
uniform vec3 sun_color;
uniform vec2 sun_screenPos;
uniform float lens_aberration;
uniform float lens_transparency;
uniform vec3 sky_blue;

uniform float vig_outter;
uniform float vig_inner;
uniform float vig_opacity;

in vec2 uv;

out vec4 o_color;

void main()
{
    vec4 s_color = texture(tex_source, uv);
    vec2 ray_distance = uv - sun_screenPos;

    /*
     * Sun Radial blur
     */
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

    /*
     * Chromatic aberration
     */
    vec2  lens_offset = (uv - 0.5) * lens_aberration * lens_aberration;
    float lensr = texture(tex_lensflare, uv - lens_offset).r;
    float lensg = texture(tex_lensflare, uv).r;
    float lensb = texture(tex_lensflare, uv + lens_offset).r;
    vec3  lens_color = vec3(lensr, lensg, clamp(lensb - sky_blue.b, 0, 1)) * sun_color;
    o_color += vec4(lens_color, 1.0) * lens_transparency;

    /*
     * Vignette
     */
    vec2  dist = uv - 0.5;
    float l = length(dist);
    float inner = min(vig_inner, vig_outter);
    float vignette = 1 - smoothstep(inner, vig_outter, l);
    o_color = mix(o_color, o_color * vignette, vig_opacity);

}