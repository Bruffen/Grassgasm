#version 330

uniform sampler2D tex_source;
in vec2 uv;

out vec4 color;

void main()
{
    color = texture(tex_source, uv);
    if (color.r + color.g + color.b < 4.0)
        color = vec4(0.0);
    
    color = clamp(color, 0.0, 1.0);
}