#version 150

layout (std140) uniform Material {
	vec4 diffuse;
};

layout (std140) uniform Matrices {
	mat4 m_pvm;
	mat4 m_view;
	mat3 m_normal;
};

layout (std140) uniform Light {
	vec4 l_dir; // global space
};

in Data{
	vec3 normal;
    vec4 position;
};

out vec4 outputF;

void main()
{
	float intensity;
	vec3 l, n;

	l = normalize(vec3(m_view * -l_dir));
	
	n = normalize(normal);
	// no need to normalize the light direction!
	intensity = max(dot(l,n),0.0);

    outputF = (0.75*intensity+0.15) * vec4 (0.72,0.58,0.38,1);
}
