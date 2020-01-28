#version 410

layout(vertices = 4) out;

uniform mat4 m_pvm;
uniform mat4 m_view;
uniform mat3 m_normal;

out vec4 posTC[];

uniform vec4 camposition;
uniform float tess_maxDistance;
uniform int tess_maxOLevel;
uniform int tess_maxILevel;
uniform float tess_outOfScreen;

in data {
    vec3 ldir;
    vec3 eye;
    vec2 uv;
} i[];

out data {
    vec3 ldir;
    vec3 eye;
    vec2 uv;
} o[];

/*
 * From https://github.com/glslify/glsl-easings
 * For visualization go to https://easings.net/
 */
float quarticOut(float t) {
	return pow(t - 1.0, 3.0) * (1.0 - t) + 1.0;
}

float qinticOut(float t) {
	return 1.0 - (pow(t - 1.0, 5.0));
}

float exponentialOut(float t) {
  return t == 1.0 ? t : 1.0 - pow(2.0, -10.0 * t);
}

void main() {
	vec4 position = gl_in[gl_InvocationID].gl_Position;
	posTC[gl_InvocationID] = position;

	int vertA;
	int vertB;

	if (gl_InvocationID == 0) {
		vertA = 0;
		vertB = 1;
	} else if (gl_InvocationID == 1) {
		vertA = 0;
		vertB = 3;
	} else if (gl_InvocationID == 2) {
		vertA = 2;
		vertB = 3;
	} else {
		vertA = 1;
		vertB = 2;
	}

	vec4 pos = (gl_in[vertA].gl_Position + gl_in[vertB].gl_Position) * 0.5;

	float maxdist_inv = 1 / tess_maxDistance;
	float dist = clamp(length(pos - camposition) * maxdist_inv, 0, 1);
		  dist = exponentialOut(dist);
		  
	float olevel = mix(tess_maxOLevel, 0, dist);
	float ilevel = mix(tess_maxILevel, 0, dist);

	vec4 ppos = (m_pvm * position);
	//vec3 spos = ppos.xyz / ppos.w;
	//This out of screen value can't be low if you want to get up close
	//if (spos.z < -tess_outOfScreen || spos.x < -tess_outOfScreen || spos.x > tess_outOfScreen) {
	//	olevel = 0;
	//	ilevel = 0;
	//}

	gl_TessLevelOuter[gl_InvocationID] = olevel;
	gl_TessLevelInner[0] = ilevel;
	gl_TessLevelInner[1] = ilevel;
    o[gl_InvocationID].ldir = i[gl_InvocationID].ldir;
    o[gl_InvocationID].eye = i[gl_InvocationID].eye;
    o[gl_InvocationID].uv = i[gl_InvocationID].uv;
}