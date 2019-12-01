#version 330

//uniform samplerCube skybox;

in data {
    vec3    position;
    vec2    light_windowPos;
    float   light_height;
} o;

out vec4 color;

void main()
{
    //vec3 tex = texture(skybox, o.position).rgb;
    float dist = length(o.light_windowPos - gl_FragCoord.xy);
    float dist_inv = 1 / dist;

    float sun_value = dist_inv * 20;
    vec3 sun_color = vec3(1.0, 1.0, 0.8) * sun_value;

    vec3 sky_base_orange = vec3(0.9, 0.4, 0.2);
    vec3 sky_base_blue = vec3(0.3, 0.5, 0.9);
    vec3 sky_base = mix(sky_base_orange, sky_base_blue, abs(o.light_height));
    vec3 sky_color = clamp(sky_base + dist_inv * sky_base, 0.0, 1.0);

    color = vec4(sky_color + sun_color, 1.0);
    //if (color.r + color.g + color.b < 3) color = vec4(0);
}