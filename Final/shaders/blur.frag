#version 440

uniform sampler2D tex_lensflare;
uniform vec2 view_size;
in vec2 uv;

out vec4 color;

void main()
{
    float kernel = 1 / 9;

    float c = 0;
    ivec2 size = ivec2(uv.x * view_size.x, uv.y * view_size.y);
    c += texelFetchOffset(tex_lensflare, size, 0, ivec2(-1, 1)).r;
    c += texelFetchOffset(tex_lensflare, size, 0, ivec2( 0, 1)).r;
    c += texelFetchOffset(tex_lensflare, size, 0, ivec2( 1, 1)).r;
    c += texelFetchOffset(tex_lensflare, size, 0, ivec2(-1, 0)).r;
    c += texelFetchOffset(tex_lensflare, size, 0, ivec2( 0, 0)).r;
    c += texelFetchOffset(tex_lensflare, size, 0, ivec2( 1, 0)).r;
    c += texelFetchOffset(tex_lensflare, size, 0, ivec2(-1,-1)).r;
    c += texelFetchOffset(tex_lensflare, size, 0, ivec2( 0,-1)).r;
    c += texelFetchOffset(tex_lensflare, size, 0, ivec2( 1,-1)).r;
    c *= kernel;
    color = vec4(c, 0, 0, 1);
    //This shader won't work and i have no idea why
    //I believe the compiler is ignoring everything above
    //so let's just output the original texture for now
    color = texture(tex_lensflare, uv);
}