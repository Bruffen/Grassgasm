#version 410

layout(vertices = 3) out;

layout (std140) uniform Matrices {
	mat4 m_pvm;
	mat4 m_view;
	mat3 m_normal;
};


out vec4 posTC[];

uniform float olevel = 64.0, ilevel= 64.0;
uniform vec4 position;

void main() {

	posTC[gl_InvocationID] = gl_in[gl_InvocationID].gl_Position;
	float maxdist = 1;
	float tessVal = 64-30*mix(0,maxdist,distance(vec4(0,position[1],0,1),posTC[0]));
	
	///float orlevel = olevel;
	///vec4 posEcra = (m_pvm*gl_in[gl_InvocationID].gl_Position);
	///if(posEcra.x<0 && posEcra.x>1 && posEcra.z<0 && posEcra.z>1 ){
	///	orlevel = 0;
	///}

	if (gl_InvocationID == 0) {
		gl_TessLevelOuter[0] = olevel;
		gl_TessLevelOuter[1] = olevel;
		gl_TessLevelOuter[2] = olevel;
		gl_TessLevelInner[0] = ilevel;
	}
}