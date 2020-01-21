#version 150

layout (std140) uniform Material {
	vec4 diffuse;
};

in Data{
	vec3 normal;
    vec4 position;
	vec3 l_dir;
};

out vec4 outputF;

void main()
{
	float intensity;
	vec3 l, n;
	
	n = normalize(normal);
	// no need to normalize the light direction!
	intensity = max(dot(l_dir,n),0.0);
	
    outputF = (0.75*intensity+0.15) * vec4 (0.72,0.58,0.38,1);
}
