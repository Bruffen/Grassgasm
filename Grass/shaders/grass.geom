#version 420
layout(triangles) in;
layout(triangle_strip, max_vertices=200) out;

uniform mat4 m_model;
uniform mat4 m_pvm;
uniform mat3 m_normal;
uniform mat4 m_p;
uniform mat4 m_viewModel;

uniform sampler2D wind;

uniform float timer;

out vec2 outUv;

in Data {
	vec3 normal;
	vec3 tangent;
	vec2 texCoord;
} DataIn[3];

//out vec3 nOut;

float random(vec2 p)
{
	vec2 K1 = vec2(
		23.14069263277926, // e^pi (Gelfond's constant)
		2.665144142690225 // 2^sqrt(2) (Gelfondâ€“Schneider constant)
	);
	return fract(cos(dot(p, K1)) * 12345.6789);
}

/*
float hash(vec2 co){
  float t = 12.9898*co.x + 78.233*co.y; 
  return fract((A2+t) * sin(t));  // any B2 is folded into 't' computation
}
*/

float ScaleValue(float min, float max, float percentage)
{
	float val = percentage * (max - min) + min;
	if (val > max)
		val = max;
	if (val < min)
		val = min;
	
	return val;
}

void GenerateVertex(vec4 pos, vec3 offset)
{
	vec4 sum = pos + vec4(offset, 0);
	gl_Position = m_pvm * (sum);
    EmitVertex();
}

mat3 AngleAxis3x3(float angle, vec3 axis)
{
	float c, s;
	c = cos(angle);
	s = sin(angle);

	float t = 1 - c;
	float x = axis.x;
	float y = axis.y;
	float z = axis.z;

	return mat3(
		t * x * x + c, t * x * y - s * z, t * x * z + s * y,
		t * x * y + s * z, t * y * y + c, t * y * z - s * x,
		t * x * z - s * y, t * y * z + s * x, t * z * z + c
		);
}

void main()
{ 
	vec3 dir;
	vec3 offset;
	int segments = 10;

	//Generate Transpose matrix
	vec3 n = DataIn[0].normal;
	vec3 b = normalize(cross(n, DataIn[0].tangent));
	vec3 t = cross(b, n);
	
	mat3 tbn_inv = transpose(mat3(t,b,n));

	float width = ScaleValue(0.01, 0.2, random(gl_in[0].gl_Position.xz));
	float height = ScaleValue(0.2, 1, random(gl_in[0].gl_Position.xz));
	//width = 0.1;
	//height = 2;

	dir = normalize(vec3(ScaleValue(0, 1, random(gl_in[0].gl_Position.xz)),0, ScaleValue(-1, 1, random(gl_in[0].gl_Position.xy))));
	
	float segment_height = height/segments;

	vec4 windIntensity = texture(wind, vec2(DataIn[0].texCoord.x + timer * 5, DataIn[0].texCoord.y));

	mat3 windMatrix = AngleAxis3x3((windIntensity.r * 3.1415), vec3(1,0,0));
	mat3 faceMatrix = AngleAxis3x3(random(gl_in[0].gl_Position.xz) * 3.1415, vec3(0,1,0));
	mat3 curvatureMatrix = AngleAxis3x3(ScaleValue(0, 80, random(gl_in[0].gl_Position.xz)), vec3(0,0,1));
	mat3 finalmatrix = windMatrix * faceMatrix * tbn_inv;

	//---------------------FRONT FACE------------------------------
	for(int i = 0; i < segments; i++)
	{
		//UVs
		outUv = vec2(0, float(i)/float(segments));

		//Height
		float h = segment_height * i;

		//Width
		float seg = float(i)/float(segments);
		vec3 transposedDir = dir * ((width * (1-seg)) * 0.5);

		//Forward curvature
		float forward = random(gl_in[0].gl_Position.xz) * 0.2;
		forward = pow(seg, 2) * forward;

		offset = finalmatrix * (m_viewModel * vec4(-transposedDir.x, forward, -h, 0)).xyz;
		GenerateVertex(gl_in[0].gl_Position, offset);

		offset = finalmatrix * (m_viewModel * vec4(transposedDir.x, forward, -h, 0)).xyz;
		GenerateVertex(gl_in[0].gl_Position, offset);
		//EndPrimitive();
	}	

	//Top Vertex
	outUv = vec2(0, 1);

	//Forward curvature
	float forward = random(gl_in[0].gl_Position.xz) * 0.2;
	forward = pow(1, 2) * forward;

	vec3 heightvec = finalmatrix * (m_viewModel * vec4(0, forward, -height, 0)).xyz;
	GenerateVertex(gl_in[0].gl_Position, heightvec);
	EndPrimitive();

	//---------------------BACK FACE------------------------------
	for(int i = 0; i < segments; i++)
	{
		//UVs
		outUv = vec2(0, float(i)/float(segments));

		//Height
		float h = segment_height * i;

		//Width
		float seg = float(i)/float(segments);
		vec3 transposedDir = dir * ((width * (1-seg)) * 0.5);

		//Forward curvature
		float forward = random(gl_in[0].gl_Position.xz) * 0.2;
		forward = pow(seg, 2) * forward;

		offset = finalmatrix * (m_viewModel * vec4(transposedDir.x, forward, -h, 0)).xyz;
		GenerateVertex(gl_in[0].gl_Position, offset);

		offset = finalmatrix * (m_viewModel * vec4(-transposedDir.x, forward, -h, 0)).xyz;
		GenerateVertex(gl_in[0].gl_Position, offset);
		//EndPrimitive();
		
	}	

	//Top Vertex
	outUv = vec2(0, 1);

	//Forward curvature
	forward = random(gl_in[0].gl_Position.xz) * 0.2;
	forward = pow(1, 2) * forward;

	heightvec = finalmatrix * (m_viewModel * vec4(0, forward, -height, 0)).xyz;
	GenerateVertex(gl_in[0].gl_Position, heightvec);
	EndPrimitive();
}

