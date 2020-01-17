#version 330

//uniform samplerCube skybox;
uniform vec3  sun_color;
uniform float sun_cutoff;
uniform float sun_fade;
uniform vec2  sun_screenPos;
uniform vec2  view_size;

in data {
    float   light_height;
} o;

out vec4 color;

void main()
{
    float dist = length(gl_FragCoord.xy - sun_screenPos * view_size);
    
    /* Simple circle */
    //float sun_value = dist < sun_cutoff ? 1.0 : 0.0;
    
    /* Fade based on distance */
    //float sun_value = (1 / dist) * sun_cutoff;
    
    /* Gaussian Distribution */
    float sun_value = pow(2.17, -(dist*dist) / (2 * pow(sun_cutoff, 2))) * sun_fade;
    
    vec3 sky_orange    = vec3(0.9, 0.4, 0.2);
    vec3 sky_blue      = vec3(0.4, 0.6, 0.9);
    vec3 sky_color     = mix(sky_orange, sky_blue, o.light_height);

    color = vec4(mix(sky_color, sun_color, sun_value), 1.0);
}