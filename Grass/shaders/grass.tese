#version 410

layout(triangles, fractional_odd_spacing, ccw) in;

uniform	mat4 m_pvm;
uniform	mat3 m_normal;

uniform float alpha = 0.75;

in vec4 normalTC[];
in vec4 posTC[];
in vec3 tangentTC[];

out Data {
	vec3 normal;
	vec3 tangent;
} DataOut;

//out vec3 normalTE;
//out vec3 tangentTE;


void main() {

	float u = gl_TessCoord.x;
	float v = gl_TessCoord.y;
	float w = gl_TessCoord.z;

	// compute normal as the weighted average of the normals for each vertex
	DataOut.normal = normalize((normalTC[0] * w + normalTC[1] * u +normalTC[2] * v).xyz);
    DataOut.tangent = normalize((tangentTC[0] * w + tangentTC[1] * u + tangentTC[2] * v).xyz);

	// compute point as weighted average of triangle vertices
	vec4 P = posTC[0] * w + posTC[1] * u +posTC[2] * v;
	
	// compute the projected points
	vec4 P0 = /* Pp=P1 - n*d */P - normalTC[0] * /* d=v*n && v=P1-P ou seja d= (P1-P) * n */dot((posTC[0] - P), normalTC[0]);
	vec4 P1 = /* Pp=P1 - n*d */P - normalTC[1] * /* d=v*n && v=P1-P ou seja d= (P1-P) * n */dot((posTC[1] - P), normalTC[1]);
	vec4 P2 = /* Pp=P1 - n*d */P - normalTC[2] * /* d=v*n && v=P1-P ou seja d= (P1-P) * n */dot((posTC[2] - P), normalTC[2]);

	// compute the weighted average of the projected points
	vec4 PS = P0 * w + P1 * u + P2 * v;

	// compute final point as a linear interpolation between P and PS with factor alpha
	vec4 res = alpha * PS + (1-alpha)*P;

	gl_Position = res;
}

