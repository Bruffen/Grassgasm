#version 330

in vec4 position;
in vec2 texCoord0;

out vec2 uv;

void main() {

	gl_Position = position;
	uv = texCoord0;
} 
