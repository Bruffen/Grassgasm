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
    vec2 uv = o.uv * tiling;
    vec3 h_diff;
    vec3 h_norm;
    vec3 h_roug;
    vec3 v_diff;
    vec3 v_norm;
    vec3 v_roug;
    
    /* Water */
    if (o.worldPos.y < 0.0)
    {
        h_diff = vec3(0.2, 0.5, 1.0);
        h_norm = vec3(0.0, 1.0, 0.0);
        h_roug = vec3(0.0, 0.0, 0.0);

        v_diff = vec3(0.2, 0.5, 1.0);
        v_norm = vec3(0.0, 1.0, 0.0);
        v_roug = vec3(0.0, 0.0, 0.0);
    }
    /* Sand */
    else if (o.worldPos.y < 1.0)
    {
        v_diff = texture(sand_diff, uv).rgb;
        v_norm = texture(sand_norm, uv).rgb * 2.0 - 1.0;
        v_roug = texture(sand_roug, uv).rgb;

        h_diff = v_diff;
        h_norm = v_norm;
        h_roug = v_roug;
    }
    /* Grass */
    else if (o.worldPos.y < 10.0)
    {
        v_diff = texture(dirt_diff, uv).rgb;
        v_norm = texture(dirt_norm, uv).rgb * 2.0 - 1.0;
        v_roug = texture(dirt_roug, uv).rgb;

        h_diff = texture(grass_diff, uv).rgb;
        h_norm = texture(grass_norm, uv).rgb * 2.0 - 1.0;
        h_roug = texture(grass_roug, uv).rgb;
    }
    /* Mountain top */
    else
    {
        v_diff = texture(rock_diff, uv).rgb;
        v_norm = texture(rock_norm, uv).rgb * 2.0 - 1.0;
        v_roug = texture(rock_roug, uv).rgb;

        h_diff = texture(snow_diff, uv).rgb;
        h_norm = texture(snow_norm, uv).rgb * 2.0 - 1.0;
        h_roug = texture(snow_roug, uv).rgb;
    }
    float normalY   = smoothstep(0.4, 0.85, o.worldNormal.y);
    vec3 diffuse    = mix(v_diff, h_diff, normalY);
    vec3 n          = mix(v_norm, h_norm, normalY);
    vec3 roughness  = mix(v_roug, h_roug, normalY);
    
    roughness *= roughness;

	float intensity = max(0.0, dot(n, o.ldir));
	vec3 h          = normalize(o.ldir + o.eye);
	float specular  = pow(max(dot(h, n), 0.0), specularity) * intensity;
    vec3 ambient = diffuse * 0.3;
    color = vec4(clamp(ambient + diffuse * 0.8 * intensity + specular *  (1 - roughness), 0, 1), 1);
    //color = vec4(o.worldPos, 1.0);
}