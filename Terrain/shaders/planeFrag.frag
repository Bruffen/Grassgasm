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
uniform int detail = 10;
out vec4 outputF;

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



float mynoise(vec2 points){
  
  points = points/10;
  float seed = 100;
  float result = 0; 
  for(int i=0;i<detail;++i)
  {
    result += (1.0/pow(2,i))*perlin(points,pow(2,i),seed+i*100);
  }
  //return smoothstep(0.0,1.6,result);
  return pow(result-0.8,2);
}

void main()
{
	float intensity;
	vec3 l, n;

	l = normalize(vec3(m_view * -l_dir));
	float OFFSET = 0.0001;
	vec4 p = position;
	vec3 f_H = vec3 (p.x+OFFSET,mynoise(vec2(p.x+OFFSET,p.z)),p.z);
	vec3 r_H = vec3 (p.x,mynoise(vec2(p.x,p.z+OFFSET)),p.z+OFFSET);
	vec3 b_H = vec3 (p.x-OFFSET,mynoise(vec2(p.x-OFFSET,p.z)),p.z);
	vec3 l_H = vec3 (p.x,mynoise(vec2(p.x,p.z-OFFSET)),p.z-OFFSET);
	vec3 calcNormal = cross(p.xyz-l_H,p.xyz-b_H)+cross(p.xyz-r_H,p.xyz-f_H);
	n = normalize(m_normal * calcNormal);
	// no need to normalize the light direction!
	intensity = max(dot(l,n),0.0);

    outputF = (0.75*intensity+0.15) * vec4 (0.72,0.58,0.38,1);
}
