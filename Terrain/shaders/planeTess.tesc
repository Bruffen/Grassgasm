#version 410

layout(vertices = 3) out;

layout (std140) uniform Matrices {
	mat4 m_pvm;
	mat4 m_view;
	mat3 m_normal;
};


out vec4 posTC[];

uniform float olevel = 100.0, ilevel= 100.0;

void main() {

	posTC[gl_InvocationID] = gl_in[gl_InvocationID].gl_Position;

	if (gl_InvocationID == 0) {
		gl_TessLevelOuter[0] = olevel;
		gl_TessLevelOuter[1] = olevel;
		gl_TessLevelOuter[2] = olevel;
		gl_TessLevelInner[0] = ilevel;
	}
}