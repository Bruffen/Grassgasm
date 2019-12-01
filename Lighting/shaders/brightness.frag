#version 330

uniform sampler2D source;

out vec4 color;

void main()
{
    color = vec4(1 - gl_FragCoord.x, 1 - gl_FragCoord.y, 0.0, 1.0);
}