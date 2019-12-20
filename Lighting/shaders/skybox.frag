#version 330

//uniform samplerCube skybox;
uniform float sun_cutoff;
uniform float sun_fade;

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
    
    /* Simple circle */
    //float sun_value = dist < sun_cutoff ? 1.0 : 0.0;
    
    /* Fade based on distance */
    //float sun_value = (1 / dist) * sun_cutoff;
    
    /* Gaussian Distribution */
    float sun_value = pow(2.17, -(dist*dist) / (2 * pow(sun_cutoff, 2))) * sun_fade;
    
    vec3 sun_color     = vec3(1.0, 1.0, 0.9);
    vec3 sky_orange    = vec3(0.9, 0.4, 0.2);
    vec3 sky_blue      = vec3(0.4, 0.6, 0.9);
    vec3 sky_color     = mix(sky_orange, sky_blue, o.light_height);    

    //color = vec4(sky_color + sun_color, 1.0);
    color = vec4(mix(sky_color, sun_color, sun_value), 1.0);
}