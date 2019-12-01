#version 330

uniform samplerCube skybox;

in data {
    vec3 position;
    vec2 light_windowPos;
} o;

out vec4 color;

void main()
{
    vec4 tex = texture(skybox, o.position);
    float dist = length(o.light_windowPos - gl_FragCoord.xy);

    color = tex + 10.0 / (dist);
}