#version 410

layout(vertices = 4) out;

layout (std140) uniform Matrices {
	mat4 m_pvm;
	mat4 m_view;
	mat3 m_normal;
};

out vec4 posTC[];

//uniform float olevel = 32.0, ilevel= 32.0;
//uniform vec4 position;
uniform vec4 camposition;
uniform float tess_maxDistance;
uniform int tess_maxOLevel;
uniform int tess_maxILevel;
uniform float tess_outOfScreen;


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
	
	//float maxdist = 1;
	//float tessVal = 64-30*mix(0,maxdist,distance(vec4(0,position[1],0,1),posTC[0]));
	
	
	//float orlevel = olevel;
	//vec4 posEcra = (m_pvm*gl_in[gl_InvocationID].gl_Position);
	//if(posEcra.x<0 && posEcra.x>1 && posEcra.z<0 && posEcra.z>1 ){
	//	orlevel = 0;
	//}
	float maxdist_inv = 1 / tess_maxDistance;
	float dist = clamp(length(position - camposition) * maxdist_inv, 0, 1);
		  dist = exponentialOut(dist);
		  
	float olevel = mix(tess_maxOLevel, 0, dist);
	float ilevel = mix(tess_maxILevel, 0, dist);

	vec4 ppos = (m_pvm * position);
	vec3 spos = ppos.xyz / ppos.w;
	//This out of screen value can't be low if you want to get up close
	//if (spos.z < -tess_outOfScreen || spos.x < -tess_outOfScreen || spos.x > tess_outOfScreen) {
	//	olevel = 0;
	//	ilevel = 0;
	//}

	if (gl_InvocationID == 0) {
		gl_TessLevelOuter[0] = olevel;
		gl_TessLevelOuter[1] = olevel;
		gl_TessLevelOuter[2] = olevel;
		gl_TessLevelOuter[3] = olevel;
		gl_TessLevelInner[0] = ilevel;
		gl_TessLevelInner[1] = ilevel;
	}
}