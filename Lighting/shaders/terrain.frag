#version 330

uniform sampler2D dirt_diff;
uniform sampler2D dirt_norm;
uniform sampler2D dirt_roug;
uniform sampler2D rock_diff;
uniform sampler2D rock_norm;
uniform sampler2D rock_roug;

uniform int specularity;
uniform vec2 tiling;

out vec4 color;

in data {
    vec3 worldPos;
    vec3 worldNormal;
    vec3 ldir;
    vec3 eye;
    vec2 uv;
} o;

void main()
{
    vec2 uv         = o.uv * tiling;
    vec3 r_diff     = texture(rock_diff, uv).rgb;
    vec3 r_norm     = texture(rock_norm, uv).rgb * 2.0 - 1.0;
    vec3 r_roug     = texture(rock_roug, uv).rgb;

    vec3 d_diff     = texture(dirt_diff, uv).rgb;
    vec3 d_norm     = texture(dirt_norm, uv).rgb * 2.0 - 1.0;
    vec3 d_roug     = texture(dirt_roug, uv).rgb;

    float normalY   = clamp(o.worldNormal.y, 0, 1);
    vec3 diffuse    = mix(r_diff, d_diff, normalY);
    vec3 n          = mix(r_norm, d_norm, normalY);
    vec3 roughness  = mix(r_roug, d_roug, normalY);
    
    roughness *= roughness;

	float intensity = max(0.0, dot(n, o.ldir));
	vec3 h          = normalize(o.ldir + o.eye);
	float specular  = pow(max(dot(h, n), 0.0), specularity) * intensity;

    color = vec4(clamp(diffuse * intensity + specular *  (1 - roughness), 0, 1), 1);
    //color = vec4(o.worldPos, 1.0);
}