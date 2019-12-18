#version 330

in vec2 uv;
uniform sampler2D tex_source;

out vec4 color;

void main()
{
    color = texture(tex_source, uv);
    if (color.r + color.g + color.b < 3.0)
        color = vec4(0.0);
    
    color = clamp(color, 0.0, 1.0);
}