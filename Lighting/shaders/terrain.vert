#version 330

uniform mat4 m_pvm;
uniform mat4 m_view;
uniform mat4 m_model;
uniform mat4 m_viewModel;
uniform mat3 m_normal;
uniform vec3 light_dir;

in vec4 position;
in vec3 tangent;
in vec3 normal;
in vec2 texCoord0;

out data {
    vec3 worldPos;
    vec3 worldNormal;
    vec3 ldir;
    vec3 eye;
    vec2 uv;
} o;

void main()
{
    /* Stuff for normal map */
	vec3 n = normalize(m_normal * normal);
	vec3 t = normalize(m_normal * tangent);
	vec3 b = normalize(cross(n, t));
	t = cross(n,b);

	mat3 tbn_inv = transpose(mat3(t, b, n));

    o.worldPos = (m_model * position).xyz;
    o.worldNormal = normalize(m_model * vec4(normal, 0)).xyz;
    o.ldir = normalize(tbn_inv * (m_view * vec4(-light_dir, 0)).xyz);
    o.eye = tbn_inv * vec3(m_viewModel * -position);
    o.uv = texCoord0;
    
    gl_Position = m_pvm * position;
}