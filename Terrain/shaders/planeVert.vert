#version 430

layout (std140) uniform Matrices {
	mat4 m_pvm;
	mat4 m_view;
	mat3 m_normal;
};

layout (std140) uniform Light {
	vec4 l_dir; // global space
};

in vec4 position;	// local space
in vec3 normal;		// local space

uniform vec4 camposition;
uniform mat4 m_model;


void main () {
  vec4 translate = m_model[3];
  vec4 posp =  m_model* (position +vec4(floor(camposition.x),0,floor(camposition.z),0)) ;
	gl_Position = vec4(posp.x,0,posp.z,1);	
}