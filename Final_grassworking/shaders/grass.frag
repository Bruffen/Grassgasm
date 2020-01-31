#version 330

uniform vec2 view_size;
uniform vec2 sun_screenPos;
uniform float scattering;
uniform float translucency;

out vec4 color;

in data {
    vec3 normal;
    vec3 ldir;
} o;

void main()
{
    float dist = length(gl_FragCoord.xy - sun_screenPos * view_size);
    /* Gaussian Distribution */
    float sun_value = pow(2.17, -(dist*dist) / (2 * pow(scattering, 2))) * translucency;
    
    vec3 grass_color = vec3(0.3, 0.8, 0);
    grass_color.r = clamp(sun_value, grass_color.r, grass_color.g);

    float ndotl  = clamp(dot(normalize(o.normal), o.ldir), 0, 1);
    vec3 ambient = grass_color         * 0.3;
    vec3 diffuse = grass_color * (ndotl + sun_value) * 0.7;
    vec3 scatter = vec3(1) * sun_value * 0.3;
    
    color = vec4(ambient + diffuse + scatter, 1);
}