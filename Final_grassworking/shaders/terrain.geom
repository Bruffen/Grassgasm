#version 420
layout(triangles) in;
layout(triangle_strip, max_vertices=200) out;

uniform mat4 m_pvm;
uniform mat4 m_model;
uniform mat3 m_normal;
uniform mat4 m_viewModel;

uniform sampler2D wind;
uniform float timer;

//Parameters
uniform float minBend = 0.01;
uniform float maxBend = 0.9;
uniform float bendFactor;
uniform float minHeight = 0.52;
uniform float maxHeight = 0.52;
uniform float minWidth = 0.07;
uniform float maxWidth = 0.19;
uniform float windStr = 2;
uniform float windVelocity = 0.0000005;

in data2 {
    vec4 position;
    vec4 worldPos;
    vec3 ldir;
    vec3 eye;
    vec2 uv;
    vec3 normal;
	vec3 tangent;
	vec3 binormal;
} i[3];

out data3 {
    vec4 position;
    vec4 worldPos;
    vec3 worldNormal;
    vec3 ldir;
    vec3 eye;
    vec3 tangent;
    vec3 normal;
    vec3 binormal;
    vec2 uv;
	vec2 windpwr;
    flat int isGrass;
} o;

float random(vec2 p)
{
	vec2 K1 = vec2(
		23.14069263277926, // e^pi (Gelfond's constant)
		2.665144142690225 // 2^sqrt(2) (Gelfondâ€“Schneider constant)
	);
	return fract(cos(dot(p, K1)) * 12345.6789);
}


float ScaleValue(float min, float max, float percentage)
{
	if (min > max)
		min = max;
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
	o.worldPos = m_model * pos;
	o.position = m_pvm * sum;
	gl_Position = o.position;
    EmitVertex();
}

void setCommonData(int index)
{
	o.ldir = i[index].ldir;
	o.eye = i[index].eye;
	o.normal = i[index].normal;
	o.binormal = i[index].binormal;
	o.tangent = i[index].tangent;
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
	int segments = 5;

	//Generate Transpose matrix
	vec3 n = normalize(m_normal *  vec3(-1,0,0));//i[0].normal;
	vec3 b = normalize(cross(n, i[0].tangent));
	vec3 t = cross(b, n);
	
	mat3 tbn_inv = transpose(mat3(t,b,n));

	//n = normalize(m_normal * vec3(0,1,0));

	vec4 tempPos = gl_in[0].gl_Position;
	//tempPos.x += (ScaleValue(-1, 1, random(gl_in[0].gl_Position.xz)));
	//tempPos.z += (ScaleValue(-1, 1, random(gl_in[0].gl_Position.xz)));

	float width = ScaleValue(minWidth, maxWidth, random(gl_in[0].gl_Position.xz));
	float height = ScaleValue(minHeight, maxHeight, random(gl_in[0].gl_Position.xz));
	//width = 0.1;
	//height = 2;

	dir = normalize(vec3(ScaleValue(-1, 1, random(gl_in[0].gl_Position.xz)),0, ScaleValue(-1, 1, random(gl_in[0].gl_Position.xy))));
	
	float segment_height = height/segments;

	vec4 windIntensity = texture(wind, vec2(i[0].uv.x + timer * (0.0000001 * windVelocity), i[0].uv.y));
	vec3 windDir = normalize(vec3(windIntensity.x, windIntensity.y,0));

	mat3 windMatrix = AngleAxis3x3((windIntensity.r * windStr), windDir);
	mat3 faceMatrix = AngleAxis3x3(ScaleValue(-10, 10, random(gl_in[0].gl_Position.xz)), vec3(0,1,0));
	mat3 randomBendMatrix = AngleAxis3x3(ScaleValue(0, 0.5, random(gl_in[0].gl_Position.xz))  * bendFactor, vec3(-1,0,0));

	mat3 finalmatrix = windMatrix * (randomBendMatrix  * (faceMatrix * tbn_inv));
	mat3 simplematrix = faceMatrix * tbn_inv;
	o.windpwr = vec2(windIntensity.x, windIntensity.z);
	//---------------------PLANE--------------------------------
	setCommonData(0);
	o.uv = i[0].uv;
	o.isGrass = 0;
    GenerateVertex(gl_in[0].gl_Position, vec3(0,0,0));
	o.uv = i[1].uv;
	o.isGrass = 0;
	setCommonData(1);
    GenerateVertex(gl_in[1].gl_Position, vec3(0,0,0));
	o.uv = i[2].uv;
	o.isGrass = 0;	
	setCommonData(2);
    GenerateVertex(gl_in[2].gl_Position, vec3(0,0,0));
    EndPrimitive();

	float grass_height = (m_model * gl_in[0].gl_Position).y;

	if (grass_height < 0.55 && grass_height > 0.015)
	{
	//---------------------FRONT FACE------------------------------
	for(int i = 0; i < segments; i++)
	{
		//UVs
		o.uv = vec2(0, float(i)/float(segments));

		//Height
		float h = segment_height * i;

		//Width
		float seg = float(i)/float(segments);
		vec3 transposedDir = dir * ((width * (1-seg)) * 0.5);

		//Forward curvature
		float forward = ScaleValue(minBend, maxBend, random(gl_in[0].gl_Position.xz)) * 0.2;
		forward = pow(seg, 2) * forward;

		mat3 m = simplematrix;
		if (i!=0)
			m = finalmatrix;

		offset = m * (m_viewModel * vec4(-transposedDir.x, forward, h, 0)).xyz;
		setCommonData(0);
		o.isGrass = 1;
		GenerateVertex(tempPos, offset);

		offset = m * (m_viewModel * vec4(transposedDir.x, forward, h, 0)).xyz;
		setCommonData(0);
		o.isGrass = 1;
		GenerateVertex(tempPos, offset);
		//EndPrimitive();
	}	

	//Top Vertex
	o.uv = vec2(0, 1);

	//Forward curvature
	float forward = ScaleValue(minBend, maxBend, random(gl_in[0].gl_Position.xz)) * 0.2;
	forward = pow(1, 2) * forward;

	vec3 heightvec = finalmatrix * (m_viewModel * vec4(0, forward, height, 0)).xyz;
	setCommonData(0);
	o.isGrass = 1;
	GenerateVertex(tempPos, heightvec);
	EndPrimitive();

	//---------------------BACK FACE------------------------------
	for(int i = 0; i < segments; i++)
	{
		//UVs
		o.uv = vec2(0, float(i)/float(segments));

		//Height
		float h = segment_height * i;

		//Width
		float seg = float(i)/float(segments);
		vec3 transposedDir = dir * ((width * (1-seg)) * 0.5);

		//Forward curvature
		float forward = ScaleValue(minBend, maxBend, random(gl_in[0].gl_Position.xz)) * 0.2;
		forward = pow(seg, 2) * forward;

		mat3 m = simplematrix;
		if (i!=0)
			m = finalmatrix;

		offset = m * (m_viewModel * vec4(transposedDir.x, forward, h, 0)).xyz;
		setCommonData(0);
		o.isGrass = 1;
		GenerateVertex(tempPos, offset);

		offset = m * (m_viewModel * vec4(-transposedDir.x, forward, h, 0)).xyz;
		setCommonData(0);
		o.isGrass = 1;
		GenerateVertex(tempPos, offset);
		//EndPrimitive();
		
	}

	//Top Vertex
	o.uv = vec2(0, 1);

	//Forward curvature
	forward = ScaleValue(minBend, maxBend, random(gl_in[0].gl_Position.xz)) * 0.2;
	forward = pow(1, 2) * forward;

	heightvec = finalmatrix * (m_viewModel * vec4(0, forward, height, 0)).xyz;
	setCommonData(0);
	o.isGrass = 1;
	GenerateVertex(tempPos, heightvec);
	EndPrimitive();
	}
}

