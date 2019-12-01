#version 330

uniform	mat4 m_proj;
uniform	mat4 m_view;
uniform vec3 light_dir;

in vec4 position;

out data {
    vec3    position;
    vec2    light_windowPos;
    float   light_height;
} o;

void main()
{
    o.position = position.xyz;

    // Remove any translations
    mat4 view = m_view;
    view[3] = vec4(0.0);
    view[0][3] = 0.0;
    view[1][3] = 0.0;
    view[2][3] = 0.0;
    view[3][3] = 0.0;
    
    vec4 light_screenPos = m_proj * view * vec4(-light_dir, 1.0);
    vec3 light_normscPos = light_screenPos.xyz / light_screenPos.w;
    // TODO replace resolution with uniform
    o.light_windowPos = (light_normscPos.xy * 0.5 + 0.5) * vec2(1280, 720);
    o.light_height = -light_dir.y;

    // Make z same as w for 1.0 depth
    gl_Position = (m_proj * view * position).xyww;
}