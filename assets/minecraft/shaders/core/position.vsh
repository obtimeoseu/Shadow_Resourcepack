#version 150

#moj_import <fog.glsl>

in vec3 Position;

uniform vec4 ColorModulator;
uniform mat4 ProjMat;
uniform mat4 ModelViewMat;
uniform int FogShape;

out float vertexDistance;
out vec4 color;

const vec3[] COLORS = vec3[](
    vec3(0.110818, 0.0, 0.0),
    vec3(0.089485, 0.0, 0.0),
    vec3(0.100326, 0.0, 0.0),
    vec3(0.114838, 0.0, 0.0),
    vec3(0.097189, 0.0, 0.0),
    vec3(0.123646, 0.0, 0.0),
    vec3(0.166380, 0.0, 0.0),
    vec3(0.091064, 0.0, 0.0),
    vec3(0.195191, 0.0, 0.0),
    vec3(0.187229, 0.0, 0.0),
    vec3(0.148582, 0.0, 0.0),
    vec3(0.235792, 0.0, 0.0),
    vec3(0.214696, 0.0, 0.0),
    vec3(0.251970, 0.0, 0.0),
    vec3(0.302066, 0.0, 0.0),
    vec3(0.331491, 0.0, 0.0)
);

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(ModelViewMat, Position, FogShape);
    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);

    color = ColorModulator;
    color.g = 0.0;
    //b *= vec3(1.0, 0.0, 1.0);

    if(vertexDistance >= 100 && vertexDistance <= 100.5)
        color = vec4(COLORS[(gl_VertexID / 4) % 16] * 2, (ColorModulator.a - 0.2) * 3.0);
}
