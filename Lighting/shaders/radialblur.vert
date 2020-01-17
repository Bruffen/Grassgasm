#version 330

in vec4 position;
in vec2 texCoord0;

out data {
	vec2 	uv;
} o;

void main()
{
	o.uv = texCoord0;
	gl_Position = position;
} 
