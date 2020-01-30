#version 430
uniform mat4 m_model;
uniform mat4 m_pvm;
uniform mat4 m_view;
uniform vec3 light_dir;
uniform vec4 camposition;

in vec4 position;
in vec3 tangent;
in vec3 normal;
in vec2 texCoord0;

out data {
    //vec3 worldPos;
    //vec3 worldNormal;
    vec3 ldir;
    //vec3 eye;
    //vec3 tangent;
    //vec3 normal;
    vec2 uv;
} o;


void main()
{
    vec4 cameraPosition = m_pvm[3];
    vec4 posp =  m_model* (position +vec4(floor(camposition.x),0,floor(camposition.z),0)) ;

    o.uv = texCoord0;
    o.ldir = normalize(/*tbn_inv **/ (m_view * vec4(-light_dir, 0)).xyz);
	  gl_Position = vec4(posp.x,0,posp.z,1);	
}