#version 410

layout(triangles, equal_spacing, ccw) in;

layout (std140) uniform Matrices {
	mat4 m_pvm;
	mat4 m_view;
	mat3 m_normal;
};

uniform mat4 m_vm; 
uniform mat4 m_pv;

in vec4 posTC[];

// the data to be sent to the fragment shader
out Data {
	vec3 normal;
  	vec4 position;
} DataOut;

#define M_PI 3.14159265358979323846

float rand(vec2 co){return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);}
float rand (vec2 co, float l) {return rand(vec2(rand(co), l));}
float rand (vec2 co, float l, float t) {return rand(vec2(rand(co, l), t));}

float perlin(vec2 p, float dim, float time) {
	vec2 pos = floor(p * dim);
	vec2 posx = pos + vec2(1.0, 0.0);
	vec2 posy = pos + vec2(0.0, 1.0);
	vec2 posxy = pos + vec2(1.0);
	
	float c = rand(pos, dim, time);
	float cx = rand(posx, dim, time);
	float cy = rand(posy, dim, time);
	float cxy = rand(posxy, dim, time);
	
	vec2 d = fract(p * dim);
	d = -0.5 * cos(d * M_PI) + 0.5;
	
	float ccx = mix(c, cx, d.x);
	float cycxy = mix(cy, cxy, d.x);
	float center = mix(ccx, cycxy, d.y);
	
	return center * 2.0 - 1.0;
}

float custom_noise(vec2 points){
    
    //return snoise(points);
    return perlin(points,1,0);
}

float mynoise(vec2 points){
  
  points = points;
  float seed = 100;
  float result = 0; 
  for(int i=0;i<5;++i)
  {
    result += (1.0/pow(2,i))*perlin(points,pow(2,i),seed+i*100);
  }
  return result;
}

void main() {

	float u = gl_TessCoord.x;
	float v = gl_TessCoord.y;
	float w = 1 - u - v;

	vec4 position = posTC[0]*w + posTC[1]*u + posTC[2]*v;
	vec4 p2 = posTC[0]*0-5 + posTC[1] + posTC[2]*0.5;
	vec4 p3 = posTC[0]*0.5 + posTC[2]*v;
	float OFFSET = distance(p2,p3)/100;

	vec4 p = position;
  	p.y += mynoise(vec2(position.x,position.z)); 
  	vec3 f_H = vec3 (p.x+OFFSET,mynoise(vec2(p.x+OFFSET,p.z)),p.z);
  	vec3 r_H = vec3 (p.x,mynoise(vec2(p.x,p.z+OFFSET)),p.z+OFFSET);
	vec3 b_H = vec3 (p.x-OFFSET,mynoise(vec2(p.x-OFFSET,p.z)),p.z);
  	vec3 l_H = vec3 (p.x,mynoise(vec2(p.x,p.z-OFFSET)),p.z-OFFSET);
  	vec3 calcNormal = normalize(cross(p.xyz-l_H,p.xyz-b_H)+cross(p.xyz-r_H,p.xyz-f_H));
	  
	DataOut.normal = normalize(m_normal * calcNormal);

	DataOut.position = p;

	gl_Position = m_pvm * p;
}

