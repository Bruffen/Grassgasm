#version 410

layout(quads, equal_spacing, cw) in;

uniform mat4 m_pvm;
uniform mat4 m_view;
uniform mat4 m_viewModel;
uniform mat3 m_normal;
uniform mat4 m_model;
uniform mat4 m_vm; 
uniform mat4 m_pv;
uniform vec4 position;
uniform vec2 tiling;
uniform int detail = 10;
in vec4 posTC[];

in data {
    vec3 ldir;
    //vec3 eye;
    vec2 uv;
} i[];

out data2{
    vec4 position;
    vec4 worldPos;
    vec3 ldir;
    vec3 eye;
    vec2 uv;
    vec3 normal;
	vec3 tangent;
	vec3 binormal;
} o;


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
    points = points/40;
    float seed = 100;
    float result = 0; 
    for(int i=0;i<detail;++i)
    {
      result += (1.0/pow(2,i))*perlin(points,pow(2,i),seed+i*100);
    }
    //return smoothstep(0.0,1.6,result);
    return 4*pow(result,3);
}

void main() {

	float u = gl_TessCoord.x;
	float v = gl_TessCoord.y;
	float w = 1 - u - v;

    vec4 p1 = mix(posTC[0], posTC[3], u);
	vec4 p2 = mix(posTC[1], posTC[2], u);
	vec4 pos = mix(p1, p2, v);
	
    // Can't get it to work
    //vec2 uv1 = mix(i[0].uv, i[3].uv, u);
    //vec2 uv2 = mix(i[1].uv, i[2].uv, u);
    //o.uv = mix(uv1, uv2, v);
    o.uv = pos.xz * tiling;
	
	float OFFSET = 0.00005;// distance(p2,p3)/100;

	vec4 p = pos; 
    p.y += mynoise(vec2(pos.x,pos.z));

    vec3 f_H = vec3 (0+OFFSET,mynoise(vec2(p.x+OFFSET,p.z)),0);
  	vec3 r_H = vec3 (0,mynoise(vec2(p.x,p.z+OFFSET)),0+OFFSET);
	vec3 b_H = vec3 (0-OFFSET,mynoise(vec2(p.x-OFFSET,p.z)),0);
	vec3 l_H = vec3 (0,mynoise(vec2(p.x,p.z-OFFSET)),0-OFFSET);
  	vec3 calcNormal = normalize(cross((0,p.y,0)-l_H,(0,p.y,0)-b_H)+cross((0,p.y,0)-r_H,(0,p.y,0)-f_H));
    
    vec3 binormal = (0,p.y,0)-b_H;
    vec3 tangent = (0,p.y,0)-l_H;
	vec3 n = normalize(m_normal * calcNormal);

    o.normal = n;
    o.binormal = binormal;
    o.tangent = tangent;

    /* 
     * Stuff for normal map 
     * Can't get it to work because of no tangent
     * and binormals in tessellation shader
	vec3 n = normalize(m_normal * calcNormal);
	vec3 t = normalize(m_normal * tangent);
	vec3 b = normalize(cross(n, t));
	t = cross(n,b);

	mat3 tbn_inv = transpose(mat3(t, b, n));

    o.worldPos = (m_model * p).xyz;
    o.worldNormal = normalize(m_model * vec4(calcNormal, 0)).xyz;
    o.ldir = normalize(tbn_inv * (m_view * vec4(-light_dir, 0)).xyz);
    o.eye = tbn_inv * vec3(m_viewModel * -p);
    o.uv = texCoord0;
     */

    o.ldir = i[0].ldir;
    o.eye = /*tbn_inv **/ vec3(m_viewModel * -p);
    o.position = p;
    o.worldPos =  p;
    gl_Position = /*m_pvm* */ p;
}