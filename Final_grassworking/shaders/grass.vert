#version 330

uniform mat4 m_pvm;
uniform mat3 m_normal;
uniform mat4 m_view;
uniform vec4 light_dir;

in vec4 position;
in vec3 normal;

out data {
    vec3 normal;
    vec3 ldir;
} o;

void main()
{
    o.normal = normalize(m_normal * normal);
    o.ldir = -normalize(m_view * light_dir).xyz;
    gl_Position = m_pvm * position;
}