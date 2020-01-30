#version 330

uniform sampler2D dirt_diff;
uniform sampler2D dirt_norm;
uniform sampler2D dirt_roug;
uniform sampler2D sand_diff;
uniform sampler2D sand_norm;
uniform sampler2D sand_roug;
uniform sampler2D rock_diff;
uniform sampler2D rock_norm;
uniform sampler2D rock_roug;
uniform sampler2D grass_diff;
uniform sampler2D grass_norm;
uniform sampler2D grass_roug;
uniform sampler2D snow_diff;
uniform sampler2D snow_norm;
uniform sampler2D snow_roug;
uniform sampler2D grass_wind;
uniform sampler2D grass_color;
uniform float red;
uniform float green;
uniform float blue;

uniform mat3 m_normal;

uniform int specularity;
uniform vec2 tiling;
uniform int detail;

out vec4 color;

in data3 {
    vec4 position;
    vec4 worldPos;
    vec3 worldNormal;
    vec3 ldir;
    vec3 eye;
    vec3 tangent;
    vec3 normal;
    vec3 binormal;
    vec2 uv;
    vec2 windpwr;
    flat int isGrass;
} i;

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

float mynoise(vec2 points) {
  
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

void main()
{
    if (i.isGrass == 0)
    {
        //vec2 uv = i.uv * tiling;
        vec3 h_diff;
        vec3 h_norm;
        vec3 h_roug;
        vec3 v_diff;
        vec3 v_norm;
        vec3 v_roug;
        
        /* Recalculate noise for normals */
        float OFFSET = 0.0001;
        vec4 p = i.worldPos;
        vec3 f_H = vec3 (0+OFFSET,mynoise(vec2(p.x+OFFSET,p.z)),0);
        vec3 r_H = vec3 (0,mynoise(vec2(p.x,p.z+OFFSET)),0+OFFSET);
        vec3 b_H = vec3 (0-OFFSET,mynoise(vec2(p.x-OFFSET,p.z)),0);
        vec3 l_H = vec3 (0,mynoise(vec2(p.x,p.z-OFFSET)),0-OFFSET);
        vec3 calcNormal = normalize(cross((0,p.y,0)-l_H,(0,p.y,0)-b_H)+cross((0,p.y,0)-r_H,(0,p.y,0)-f_H));
        vec3 n = normalize(m_normal * calcNormal);
        vec2 uv = i.worldPos.xz * tiling;

        /* Water */
        if (i.worldPos.y < 0.0)
        {
            h_diff = vec3(0.2, 0.5, 1.0);
            //h_norm = vec3(0.0, 1.0, 0.0);
            h_roug = vec3(0.0, 0.0, 0.0);

            v_diff = vec3(0.2, 0.5, 1.0);
            //v_norm = vec3(0.0, 1.0, 0.0);
            v_roug = vec3(0.0, 0.0, 0.0);
        }
        /* Sand */
        else if (i.worldPos.y < 1.0)
        {
            v_diff = texture(sand_diff, uv).rgb;
            //v_norm = texture(sand_norm, uv).rgb * 2.0 - 1.0;
            v_roug = texture(sand_roug, uv).rgb;

            h_diff = v_diff;
            //h_norm = v_norm;
            h_roug = v_roug;
        }
        /* Grass */
        else if (i.worldPos.y < 10.0)
        {
            v_diff = texture(dirt_diff, uv).rgb;
            //v_norm = texture(dirt_norm, uv).rgb * 2.0 - 1.0;
            v_roug = texture(dirt_roug, uv).rgb;

            h_diff = texture(grass_diff, uv).rgb;
            //h_norm = texture(grass_norm, uv).rgb * 2.0 - 1.0;
            h_roug = texture(grass_roug, uv).rgb;
        }
        /* Mountain top */
        else
        {
            v_diff = texture(rock_diff, uv).rgb;
            //v_norm = texture(rock_norm, uv).rgb * 2.0 - 1.0;
            v_roug = texture(rock_roug, uv).rgb;

            h_diff = texture(snow_diff, uv).rgb;
            //h_norm = texture(snow_norm, uv).rgb * 2.0 - 1.0;
            h_roug = texture(snow_roug, uv).rgb;
        }
        
        float normalY   = smoothstep(0.4, 0.85, calcNormal.y);
        //float normalY   = smoothstep(0.4, 0.85, o.worldNormal.y);
        vec3 diffuse    = mix(v_diff, h_diff, normalY);
        //vec3 n          = mix(v_norm, h_norm, normalY);
        vec3 roughness  = mix(v_roug, h_roug, normalY);
        
        roughness *= roughness;

        float intensity = max(0.0, dot(n, i.ldir));
        vec3 h          = normalize(i.ldir + i.eye);
        float specular  = pow(max(dot(h, n), 0.0), specularity) * intensity;
        vec3 ambient = diffuse * 0.3;
        color = vec4(clamp(ambient + diffuse * 0.8 * intensity + specular * (1 - roughness), 0, 1), 1);
    } else {
        vec2 uvs = vec2(i.uv.y, i.uv.x);
	    vec4 c = texture(grass_color, uvs);
	    float windEffect = 0.90;

	    if (i.windpwr.x > 0.55 && uvs.x > 0.6)
	    	windEffect = 1;

	    vec4 finalColor = c * windEffect;
	    finalColor.r *= red;
	    finalColor.g *= green;
	    finalColor.b *= blue;

	    if (i.windpwr.x == -1)
	    	color = c;
	    else
	    	color = finalColor;//vec4(0, lerp.y, 0, 0);
    }
    //color = vec4(p.xz, 0.0, 1.0);
}
