#version 330 core

#define PI 3.1415926538
#define TWO_PI (2*PI)

uniform mat4 obj_mat;
uniform mat4 proj_mat;
uniform mat4 view_mat;
uniform mat3 normal_mat;
uniform float torsion;

in vec3 vtx_position;
in vec3 vtx_normal;
in vec2 vtx_texcoord;

out vec3 v_normal;
out vec2 v_uv;
out mat3 test;

vec3 circle(float uv, float r){
    vec3 c;
    c.x = 0;
    c.y = r * sin(TWO_PI * uv);
    c.z = r * cos(TWO_PI * uv);
    return c;
}

vec3 square(float uv, float length){
    vec3 c = vec3(0);

    if (uv < 0.25){
        c.y = -length/2;
        c.z = ((uv * 4) - 0.5) * length ;
    } else if (uv < 0.5) {
        c.z = length/2;
        c.y = (((uv -0.25) * 4) - 0.5) * length ;
    } else if (uv < 0.75) {
        c.y = length/2;
        c.z = -(((uv -0.50)* 4) - 0.5) * length ;
    } else {
        c.z = -length/2;
        c.y = -(((uv -0.75)* 4) - 0.5) * length ;
    }
    return c;
}

mat3 rotation(float rad){
    mat3 rot;
    rot[0] = vec3(1, 0, 0);
    rot[1] = vec3(0, cos(rad), sin(rad));
    rot[2] = vec3(0, -sin(rad), cos(rad));
    return rot;
}


mat3 getTBN(vec3 T){
    vec3 N = normalize(cross(vec3(T.y + 1, -T.x, T.z), T));
    vec3 BN = normalize(cross(T, N));
    test = mat3(T, BN, N);
    return test;
}


vec3 bezier4(vec3 p0, vec3 p1, vec3 p2, vec3 p3, float u, out vec3 T) {
    vec3 p01 = p0 + u * (p1 - p0);
    vec3 p11 = p1 + u * (p2 - p1);
    vec3 p21 = p2 + u * (p3 - p2);

    vec3 p02 = p01 + u * (p11 - p01);
    vec3 p12 = p11 + u * (p21 - p11);

    T = normalize(p12 - p02);

    return p02 + u * (p12 - p02);
}

vec3 cylBezier(float u, float v, float r, vec3 b0, vec3 b1, vec3 b2, vec3 b3) {
    vec3 T;
    vec3 center = bezier4(b0, b1, b2, b3, u, T);
    mat3 TBN = getTBN(normalize(T));
    vec3 extruded =  TBN  * rotation(torsion * u) * square(v, r);
    return center + extruded;
}

vec3 cylinder(float u, float v, vec3 A, vec3 B, float r) {
    vec3 vecAB = B - A;
    vec3 center = A + u * vecAB;
    mat3 TBN = getTBN(normalize(vecAB));
    vec3 extruded = TBN * circle(v, r);
    return center + extruded;
}

vec3 s(float u, float v) {
    return cylBezier(u, v, 0.3, vec3(-0.5, -1, -1), vec3(1.5, 1, -0.3), vec3(-1.5, 1, 0.3), vec3(0.5, -1, 1));
}

void main() {
    v_uv  = vtx_texcoord;
    v_normal = normalize(normal_mat * vtx_normal);
    vec4 p = view_mat * (obj_mat * vec4(s(vtx_texcoord.s, vtx_texcoord.t), 1.));
    gl_Position = proj_mat * p;
}
