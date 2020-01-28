#version 420

in vec4 position;
in vec3 normal;
in vec3 tangent;
in vec2 texCoord0;

uniform mat4 m_model;
uniform mat3 m_normal;
uniform mat4 m_pvm;
uniform mat4 m_p;


out Data {
	vec3 normal;
	vec3 tangent;
	vec2 texCoord;
} DataOut;

void main()
{
	//Normal
	vec3 n = normalize(m_normal * normal);
	DataOut.normal = n;

	//Tangent
	vec3 t = normalize(m_normal * tangent);
	DataOut.tangent = t;

	DataOut.texCoord = texCoord0;

	gl_Position = position;
} 

/*
out vec4 posV;
out vec4 normalV;
out vec3 tangentV;

void main() {

	normalV = normal;
    posV =  position;
	tangentV = tangent;
}
*/