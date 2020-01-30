#version 420

uniform sampler2D wind;
uniform sampler2D color;
uniform float red;
uniform float green;
uniform float blue;

uniform float timer;

in vec2 outUv;
in vec2 windpwr;
out vec4 outputF;

void main()
{
	vec3 bottomColor = vec3(0, 0.2, 0);
	vec3 topColor = vec3(0, 1.5, 0);

	vec3 lerp = mix(bottomColor, topColor, outUv.y);

	vec2 uvs = vec2(outUv.y, outUv.x);
	vec4 c = texture(color, uvs);
	float windEffect = 0.90;

	if (windpwr.x > 0.55 && uvs.x > 0.6)
		windEffect = 1;

	vec4 finalColor = c * windEffect;
	finalColor.r *= red;
	finalColor.g *= green;
	finalColor.b *= blue;

	if (windpwr.x == -1)
		outputF = c;
	else
		outputF = finalColor;//vec4(0, lerp.y, 0, 0);
} 
