#version 420

uniform sampler2D wind;
uniform sampler2D color;

uniform float timer;

in vec2 outUv;
out vec4 outputF;

void main()
{
	vec3 bottomColor = vec3(0, 0.2, 0);
	vec3 topColor = vec3(0, 1.5, 0);

	vec3 lerp = mix(bottomColor, topColor, outUv.y);

	vec2 uvs = vec2(outUv.y, outUv.x);
	vec4 c = texture(color, uvs);

	outputF = c;//vec4(0, lerp.y, 0, 0);
} 
