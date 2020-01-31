#version 330

uniform sampler2D tex_brightness;
uniform vec2 sun_screenPos;
uniform float ghost_spacing;
uniform float ghost_threshold;
uniform int ghost_count;

in vec2 uv;

out vec4 color_out;

vec3 apply_threshold(vec3 color, float threshold)
{
	return max(color - vec3(threshold), vec3(0.0));
}

void main()
{
    vec4 color = texture(tex_brightness, uv);

    vec2 fuv = vec2(1.0) - uv; // flip the texture coordinates
    vec3 ret = vec3(0.0);
    vec2 ghost_dist = (vec2(0.5) - fuv) * ghost_spacing;
    for (int i = 0; i < ghost_count; i++) 
    {
    	vec2 suv = fract(fuv + ghost_dist * vec2(i));
    	float d = distance(suv, vec2(0.5));
    	float weight = 1.0 - smoothstep(0.0, 0.75, d); // reduce contributions from samples at the screen edge
    	vec3 s = texture(tex_brightness, suv).xyz;
    	s = apply_threshold(s, ghost_threshold);
    	ret += s * weight;
    }
    color_out = vec4(ret, 1.0);
}