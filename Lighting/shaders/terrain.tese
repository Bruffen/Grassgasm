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

vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v){
    const vec4 C = vec4(0.211324865405187, 0.366025403784439,
             -0.577350269189626, 0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod(i, 289.0);
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
    + i.x + vec3(0.0, i1.x, 1.0 ));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
      dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}


vec4 permute4(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec2 P){
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;
    vec4 i = permute4(permute4(ix) + iy);
    vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
    vec4 gy = abs(gx) - 0.5;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);
    vec4 norm = 1.79284291400159 - 0.85373472095314 * 
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

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

float custom_noise(vec2 points,float dim, float seed){
    return snoise((points*dim+seed));
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
    o.worldPos = m_model * p;
    gl_Position = /*m_pvm* */ p;
}